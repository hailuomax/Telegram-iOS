//
//  HLSDK.swift
//  TelegramUI#shared
//
//  Created by 黄国坚 on 2020/8/11.
//

import Foundation
import Display
import HLBase
import TelegramPresentationData
import UI
import Account
import PromiseKit
import HL
import Model

extension HLSDK{
    
    ///判断是否
    static func url(_ url: URL, context: AuthorizedApplicationContext?, authContext: UnauthorizedApplicationContext?) -> Bool{
        
        //判断这次唤醒源头是否从sdk
        var isSDK: Bool = false
        //海螺sdk唤醒处理
        if url.scheme == "hailuo",
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems,
            let host = components.host,
            let typeSDK = SDKType(rawValue: host),
            let nv: NavigationController = [context?.rootController,
                                            authContext?.rootController].compactMap{$0 as? NavigationController}.first,
            let presentationData: PresentationData = [context?.context.sharedContext.currentPresentationData.with {$0},
                                                      authContext?.sharedContext.currentPresentationData.with {$0}].compactMap{$0 as? PresentationData}.first {
            
            let param = queryItems.reduce(into: [String:String]()) { result, item in
                result[item.name] = item.value ?? ""
            }
            print(param)
            
            typeSDK.handel(with: param, navigationController: nv, presentationData: presentationData)
            
            isSDK = true
        }
        
        return isSDK
    }
}

///SDK唤醒的类型
enum SDKType: String {
    
    ///授权
    case authorization
    ///支付
    case pay
    ///充值
    case recharge
    ///提币
    case withdrawal
    
    private static var shareNavigationController: NavigationController!
    private static var sharePresentationData: PresentationData!
    
    func handel(with param: [String:String], navigationController: NavigationController, presentationData: PresentationData){
        
        SDKType.shareNavigationController = navigationController
        SDKType.sharePresentationData = presentationData
        
        var nextVC: ViewController
        switch self {
        case .authorization:
            guard let openId: String = param["appId"] else {
                HUD.flash(.label("appId无效"))
                return }
            
            authorization()
            
            return
        case .pay,
             .recharge,
             .withdrawal:
            
            nextVC = HLBaseVC<BaseWkWebView>(presentationData: presentationData).then{
                $0.contentView.load(urlStr: "https://www.baidu.com", jsNames: [], onListen: {_,_  in})
            }
        }
        
        navigationController.pushViewController(nextVC)
    }
    
    
    /// 授权流程
    private func authorization(){
        
        firstly{
            getAccessToken()
        }
        .done{ accessToken in
            HLSDKAuthorizationVC.show(presentationData: SDKType.sharePresentationData, navigationController: SDKType.shareNavigationController, accessToken: accessToken)
        }
        .catch{_ in
            
        }
    }
    
    /// 获取 accessToken
    /// - Returns: accessToken
    private func getAccessToken() -> Promise<String>{
        
        return Promise<String>{ reslover in
            
            if HLAccountManager.walletIsLogined{
                print("已登录，直接从本地获取AccessToken")
                HLSDK.shareAccessToken = HLAccountManager.shareAccount.token!
                reslover.fulfill(HLAccountManager.shareAccount.token!)
            }else{
                let nextVC: HLSDK.Login.PhoneInputVC = HLSDK.Login.PhoneInputVC(presentationData: SDKType.sharePresentationData, onGetUserToken: {
                    print("LoginUserToken", $0)
                    HLSDK.shareAccessToken = $0.token
                    reslover.fulfill($0.token)
                })
                SDKType.shareNavigationController.pushViewController(nextVC)
            }
        }
    }
}

