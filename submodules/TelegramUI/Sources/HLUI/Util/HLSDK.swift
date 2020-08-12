//
//  HLSDK.swift
//  TelegramUI#shared
//
//  Created by 黄国坚 on 2020/8/11.
//

import Foundation

class HLSDK{
    
    ///判断是否
    static func url(_ url: URL, context: AuthorizedApplicationContext?, authContext: UnauthorizedApplicationContext?) -> Bool{
        
        var isSDK: Bool = false
        //海螺sdk唤醒处理
        if url.scheme == "hailuo",
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems{
            
            let host = components.host
            guard let type = SDKType(rawValue:host) else {break}
            
            let param = queryItems.reduce(into: [String:String]()) { result, item in
                result[item.name] = item.value ?? ""
            }
            print(param)
        }
        
        return isSDK
    }
}

///SDK唤醒的类型
enum SDKType: String {
    
    case login
    case pay
    case recharge
    case withdrawl
    
    
}
