//
//  JY+String.swift
//  TelegramUI
//
//  Created by 黄国坚 on 2019/9/29.
//  Copyright © 2019 Telegram. All rights reserved.
//

import Foundation


extension JY where Base == String {

    /// 字符串的md5属性
    var MD5String: String {

        return base.md5()
    }
    
    /// base64编码
    func base64Encoding() -> String {
        let plainData = base.data(using: .utf8)
        let base64String = plainData?.base64EncodedString()
        return base64String!
    }
    /// base64解码
   func base64Decoding() -> String {
    
        let decodedData = Data(base64Encoded: base)
        let decodedString = String(data: decodedData!, encoding: .utf8)
        return decodedString!
    }
    ///
	func base64Data() -> [UInt8] {
        
        return [UInt8](Data(base64Encoded: base)!)
    }
    
    // 签名
    func signatureStr() -> String {
        let sign = self.MD5String
		
        let firstIndex = sign.index(sign.startIndex, offsetBy: 4)
		//1.只要0到34下标的字段 2.从下标4开始拿
		let signature = String(String(sign.prefix(35))[firstIndex...])
        let signatureUp = signature.uppercased()
        return signatureUp
    }
    
    /// 密码相关加密
    func encryptStr(_ type: EncryptEnum) -> String {
        let sign = self.MD5String.uppercased()
        
        let range = type.range()
        
        let startIndex: String.Index = sign.index(sign.startIndex, offsetBy: range.start)
        let endIndex: String.Index = sign.index(sign.startIndex, offsetBy: range.end)
        
        let newSign = sign[startIndex...endIndex]
       
        return String(newSign)
    }
}

///密码相关的加密方式枚举
enum EncryptEnum{
    ///支付密码 5到12位
    case payPwd
    ///手势密码 6到12
    case gesturesPwd
    
    func range() -> (start: Int, end: Int){
        switch self{
        case .payPwd:
            return (5, 12)
        case .gesturesPwd:
            return (6, 12)
        }
    }
}
