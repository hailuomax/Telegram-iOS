import Foundation
import Postbox
import SwiftSignalKit
import PromiseKit
//import class SwiftSignalKit.Signal
import SyncCore

import HL
import MtProtoKit


public let kFirstSetAIPEnvironment = "kFirstSetAIPEnvironment"
///是否在app终止时清空本地代理列表
public let kLocalProxyListShouldClearKey = "kLocalProxyListShouldClearKey"


/// 内置代理的工具
class ProxyManager: NSObject {
    
    var list: [ProxyServerSettings] = []
    var accountManager: AccountManager!
    var network: Network? = nil
    private let statusDisposable = MetaDisposable()
    var hadLoad: Bool = false
    
    static let shared = ProxyManager()
    
    
    /// 设置网络
    /// - Parameter network: 网络
    @discardableResult
    func setNetWork(_ network: Network) -> Self {
        self.network = network
        return self
    }
    
    private lazy var onceCode: Void = {
        
        PlainPing.ping("api.telegram.org", withTimeout: 5.0, completionBlock: { (timeElapsed:Double?, error:Error?) in
            if let latency = timeElapsed {
                print("latency (ms): \(latency)")
            }else if let error = error {
                print("error: \(error.localizedDescription)")
                ProxyManager.checkLocalProxyList(UserDefaults.standard.bool(forKey: kLocalProxyListShouldClearKey))
                
                UserDefaults.standard.set(false, forKey: kLocalProxyListShouldClearKey)
                UserDefaults.standard.synchronize()
            }
        })
    }()
    
    func start() {
//        guard APPConfig.environment != .appStore else {return}
        _ = onceCode
    }
    
    
    /// 设置当前代理
    /// - Parameter proxy: 服务器代理
    private func setCurrentProxy(_ proxy: ProxyServerSettings) {
        guard let accountManager = self.accountManager else { return }
        ProxyManager.refreshAPIEnvironmnet(proxy)
        _ = updateProxySettingsInteractively(accountManager: accountManager, { current in
            //关闭\开启内置翻墙
            //setNetshieldSwitch(false)
            var current = current
            current.defaultEnabled = true
            current.activeServer = proxy
            current.enabled = true
            return current
        }).start()
    }
    
    //MARK: - 本地检查代理流程相关
    private let kLocalProxyListKey = "kLocalProxyListKey"
    
    
    ///获取海螺请求下来保存到本地的代理 字符串
    private func getLocalProxyList() -> [ProxyServerSettings]{
        guard let str = UserDefaults.standard.string(forKey: kLocalProxyListKey) else {
            self.list = []
            return []
        }
        self.list = factoryProxyList(from: str)
        return self.list
    }
    ///保存请求下来的代理 字符串
    private func saveLocalProxyList(_ str: String){
        UserDefaults.standard.set(str, forKey: kLocalProxyListKey)
        UserDefaults.standard.synchronize()
    }
    
    /// 通过字符串传话成ProxyServerSettings数组
    private func factoryProxyList(from str: String) -> [ProxyServerSettings]{
        let proxyServerList: [String] = str.toArray()
        print("生成的代理列表:\(proxyServerList)")
        return self.getServerList(proxyServerList)
    }
    
    @discardableResult
    /// 检测海螺提供的代理的流程
    public static func checkLocalProxyList(_ mustCheckLocal: Bool = false) -> PromiseKit.Promise<Bool>{
        
        return PromiseKit.Promise<Bool>{ reslover in
            _ = updateProxySettingsInteractively(accountManager: shared.accountManager, { proxySettings in
                
                let localProxyList = shared.getLocalProxyList()
                
                let activeServer = proxySettings.activeServer
                ProxyManager.refreshAPIEnvironmnet(activeServer)
                guard mustCheckLocal || (activeServer == nil) || localProxyList.contains(activeServer!) else {return proxySettings}//用户开启自己的代理，就不用管了
                
                
                let defaultEnabled = mustCheckLocal ? mustCheckLocal : proxySettings.defaultEnabled
                //关闭\开启内置翻墙
                //setNetshieldSwitch(defaultEnabled)
                
                guard defaultEnabled else {return proxySettings} //用户没开启海螺提供的代理，就不用管了
                
                defer{
                    shared.checkStatusAndApply((mustCheckLocal || activeServer == nil) ? [] : [activeServer!]) //判断当前使用
                        .then({
                            shared.checkStatusAndApply(shared.getLocalProxyList()) //获取本地保存的代理,并检查可用
                        })
                        .then ({
                            shared.requestProxyList()
                        })
                        .then({
                            shared.checkStatusAndApply(shared.list)
                        })
                        .done({
                            print("没有可用，被迫跳出")
                            reslover.fulfill(false)
                        })
                        .catch({_ in
                            print("有可用，跳出")
                            reslover.fulfill(true)
                        })
                }
                return proxySettings
            }).start()
        }
    }
    
    /// 清除缓存代理
    public static func clearLocalProxyList(){
        shared.saveLocalProxyList("")
    }
    
    //MARK: -
    
    /// 从服务器获取代理列表，可用，这设为当前代理
    public func requestProxyList() -> PromiseKit.Promise<Void> {
        
        return PromiseKit.Promise<Void> { resolver in
            
            guard let url = URL(string: "http://src.i7.app") else {  return }
            var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request) { [weak self] (data, respons, error) in
                guard respons != nil,
                    let data = data,
                    let self = self else {return}
                let newStr = String(data: data, encoding: String.Encoding.utf8)
                //使用AES-128-ECB加密模式
                guard let decodeStr = EncryptManager.shared.aesDecrypt(newStr!, "bikQIdKJ4Goq9jqw", "4469116275869636") else{return}
                print("网络请求下来的代理")
                self.list = self.factoryProxyList(from: decodeStr)
                //保存本地
                self.saveLocalProxyList(decodeStr)
                resolver.fulfill(())
                
            }
            dataTask.resume()
            
        }
    }
    
    private func test() {
        let proxyServerList: [String] =  ["tg://proxy?port=1082&server=192.168.123.54","tg://proxy?port=1082&server=192.168.123.55"]
        let serverList = self.getServerList(proxyServerList)
        self.list = serverList
        self.checkStatusAndApply(self.list)
    }
    
    
    /// 代理服务器列表
    private func getServerList(_ serverList: [String]) -> [ProxyServerSettings] {
        var proxyList: [ProxyServerSettings] = []
        for index in 0 ..< serverList.count {
            let proxyServerLink: String = serverList[index]
            let urlComponents = NSURLComponents(string: proxyServerLink)
            let queryItems = urlComponents?.queryItems
            var server: String = ""
            var port: Int32 = 0
            var userName: String? = nil
            var password: String? = nil
            var secret: String? = nil
            if let queryItems = queryItems {
                for item in queryItems {
                    if item.name == "server" {
                        server = item.value ?? ""
                    } else if item.name == "port" {
                        port = Int32(item.value ?? "0") ?? 0
                    } else if item.name == "userName" {
                        userName = item.value
                    } else if item.name == "password" {
                        password = item.value
                    } else if item.name == "secret" {
                        secret = item.value
                    }
                }
            }
            
            if let userName = userName {//暂时不加入socket5的检测，容易被封
//                let proxy = ProxyServerSettings(host: server, port: port, connection: .socks5(username: userName, password: password))
//                proxyList.append(proxy)
            } else if let secret = secret {
                let secretData = MTProxySecret.parse(secret)
                if let secretData = secretData {
                    let proxy = ProxyServerSettings(host: server, port: port, connection: .mtp(secret: secretData.serialize()))
                    proxyList.append(proxy)
                }
            }
            
        }
        return proxyList
    }
    
    
    /// 检查网络并应用
    /// - Parameter serverList: 服务器的链接列表
    private func checkStatusAndApply(_ serverList: [ProxyServerSettings]) -> PromiseKit.Promise<Void> {
        
        var serverList = serverList
        
        return PromiseKit.Promise<Void>{ resolver in
            
            guard let network = self.network else { return }
            
            //检测一个代理的可用性 result(true:可用)
            func checkStatus(result: @escaping (Bool) -> ()){
                
                guard let proxy = serverList.first else {
                    result(false)
                    return
                }
                
                let statusesContext = ProxyServersStatuses(network: network, servers: .single([proxy]))
                self.statusDisposable.set((statusesContext.statuses()
                    |> map { return $0.first?.value }
                    |> distinctUntilChanged
                    |> deliverOnMainQueue).start(next: { [weak self] status in
                        guard let self = self, let status = status else {return}
                        
                        switch status {
                        case .checking:
                            break
                        case .available(_):
                            debugPrint("---->网络可用")
                            self.setCurrentProxy(proxy) //并应用
                            result(true)
                            
                        case .notAvailable:
                            debugPrint("---->网络不可用，重新检测其他")
                            serverList.removeFirst()
                            checkStatus(result: result)
                        }
                        
                    }))
            }
            
            checkStatus(){
                if $0 {
                    let error = NSError(domain:"PromiseKitTutorial", code: 0,userInfo: [NSLocalizedDescriptionKey: "可用，跳出"])
                    resolver.reject(error)
                }else{
                    resolver.fulfill(()) //继续走流程
                }
            }
            
        }
    }
    
    public class func refreshAPIEnvironmnet(_ setting : ProxyServerSettings?){
        guard let s = setting,UserDefaults.standard.value(forKey: kFirstSetAIPEnvironment) == nil else {return}
        UserDefaults.standard.set("1", forKey: kFirstSetAIPEnvironment)
        ProxyManager.shared.network?.context.updateApiEnvironment { ( env ) -> MTApiEnvironment? in
             let env1 =  env?.withUpdatedSocksProxySettings(s.mtProxySettings)
            return env1
        }
    }
}
