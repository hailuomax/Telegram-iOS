//
//  AccountModel.swift
//  TelegramUI
//
//  Created by 黄国坚 on 2019/9/28.
//  Copyright © 2019 Telegram. All rights reserved.
//

import Foundation
import SyncCore
import Language

///海螺用户管理器
public struct HLAccountManager {
	
    ///存userdefault的key
    public static let shareAccountKey = "HLAccountManager_ShareAccount"
    
    /// 存开车群开车开关的key
    public static let canDriveKey = "HLAccountManager_canDriveKey"
    
    /// 接收TelegramUser变化的NotificationName
    public static let kTelegramUserDidChangeNotificationName: Notification.Name = Notification.Name(rawValue: "kTelegramUserDidChangeNotificationName")
    
	///单例
    public static var shareAccount: AccountM = AccountM(payPwdStatus: 0, gestureStatus: 0)
	
	///单例，当前电报账号信息
    public private(set) static var shareTgUser: TelegramUser!
    
    ///单例，当前语言版本
    public static var shareLanguageCode: LanguageCodeEnum{
        get{
            return LanguageCode.share
        }
        set(value){
            LanguageCode.share = value
        }
    }
    
    /// 调用用该方法设置user,然后根据通知，通知调用
    public static func setShareTgUser(_ user: TelegramUser){
        
        DispatchQueue.main.sync {//避免并发出现问题
            if shareTgUser != nil { //为空时，是开启app，不用清token
                _ = cleanToken()
            }
            
            let shouldPost = shareTgUser == nil || shareTgUser!.id != user.id
            
            shareTgUser = user
            
            if shouldPost { //说明是1.刚启动app 2.另一个账号，需要请求该用户的开车状态
                
                NotificationCenter.default.post(name: kTelegramUserDidChangeNotificationName, object: nil)
            }
        }
    }
    
    /// 清除token
    public static func cleanToken() -> HLAccountManager.Type{
        shareAccount.token = ""
        return HLAccountManager.self
    }
    
    
    /// 判断是否开启开车功能
    public static func canDrive() -> Bool{
        
        let canDrive = UserDefaults.standard.bool(forKey: HLAccountManager.canDriveKey)
        //print("canDrive -> \(canDrive)")
        return canDrive
    }
}

///海螺账号model
public struct AccountM: Codable {
	
	public var token: String?
	///财路绑定状态，0 待绑定，1 已绑定
	public var cailuwBindStatus: Int?
	///实名认证状态，1：未认证 2：审核中 3：已认证 4：认证失败
	public var certificateStatus: CertificateStatus?
	/// 交易密码设置状态，0 未设置，1 已设置
	public var payPwdStatus: Int
    public var oldTelephone: String?
    public var oldPhoneCode: String?
    /// 0 正常；1 手机不一致
    public var phoneStatus: Int?
    ///手势密码状态【0：未设置，1：已设置】
    public var gestureStatus: Int?
    ///校验码（手势密码未设置的时候返回用于设置手势的凭证）
    public var verifyCode: String?
    ///交易密码错误次数
    public var pwdErrorTimes: Int?
    ///交易密码总次数
    public var pwdErrorTotalTimes: Int?
}

/// 实名认证状态
public enum CertificateStatus: Int, Codable {
	
	///未认证
	case uncertificated = 1
	///审核中
	case inReview
	///已认证
	case certified
	///认证失败
	case failed
}

//MARK: - 请求返回的模型
///验证码收到后的倒计时
public struct CodeSeconds: Codable {
	public let seconds: Int
}
///绑定财路账号返回结果
public struct BindStatusM: Codable{
	public let bindStatus: Bool
}

//MARK: - 检查海螺账户（用户）状态（登录前置接口
public struct UserStatusCheckM: Codable{
    ///用户状态 （屏蔽状态）【2：正常，3：禁用】，账户无法登录，无法交易，只能人工后台解除
    public let status: Int
    ///登录锁定【false：未锁定，true：锁定】，账户不可登录，不可交易，24小时自动解锁或人工解锁
    public let loginLockStatus: Bool
    /// 手势密码状态【false：未设置，true：已设置】
    public let gestureStatus: Bool
    /// 旧手机号 （phoneStatus状态1时才返回）
    public let oldTelephone: String?
    /// 旧国家区号（phoneStatus状态1时才返回）
    public let oldPhoneCode: String?
    /// 0 正常；1 手机不一致
    public let phoneStatus: Int?
    /// 交易密码设置状态，0 未设置，1 已设置
    public let payPwdStatus: Int?
    /// 是否满18岁【true/false】
    public let full18Years: Bool
    /// 是否展示敏感信息【true/false】
    public let showSensitive: Bool
    
    ///判断是否可以开车
    public func canDrive() -> Bool{
        return full18Years && showSensitive
    }
}

//MARK: - 手机验证码验证后返回的模型
public struct PhoneVerifyM: Codable{
    public let verifyCode: String
}
