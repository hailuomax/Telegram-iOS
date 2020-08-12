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

class HLSDK{
    
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
    
    case login
    case pay
    case recharge
    case withdrawal
    
    func handel(with param: [String:String], navigationController: NavigationController, presentationData: PresentationData){
        
        switch self {
        case .login,
             .pay,
             .recharge,
             .withdrawal:
            
            let testWebVC = HLBaseVC<BaseWkWebView>(presentationData: presentationData).then{
                $0.contentView.load(urlStr: "https://www.baidu.com", jsNames: [], onListen: {_,_  in})
            }

            navigationController.pushViewController(testWebVC)
        }
    }
}

