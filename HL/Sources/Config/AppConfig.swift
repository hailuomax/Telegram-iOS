//
//  AppConfig.swift
//  HL
//
//  Created by 黄国坚 on 2020/3/23.
//

import Foundation

///管理APP配置相关
public struct APPConfig {
    
    ///环境切换开关，只需要改值，其他地方不用动！
    public static let environment: Environment = .testFlight
    
    ///项目配置，登录时是否需要校验输入邀请码
    public static var needCheckInvitationCode: Bool {
        
//        return environment != .appStore && environment != .testFlight
        return false
    }
    
    ///渠道号，20-GM官方正式版，21-appstore  22-testflight
    public static var channelId: String{
        switch environment {
        case .GM: return "20"
        case .appStore: return "21"
        case .testFlight, .test, .dev: return "22"
        }
    }
    ///国际化
    public static var locale: AppLocalEnum {
        
        /// FIXME: - 记得改回来
        //let code = HLAccountManager.shareLanguageCode
        let code = LanguageCodeEnum.SC
        
        switch code {
        case .SC:
            return .zh_CN
        case .TC:
            return .zh_TW
        case .EN:
            return .en_US
        }
    }
    
    ///是否加密
    public static let isEncryption = "1"
    ///与服务器的时间差
    public static var dateDif : Int = 0
    
}

//MARK: - 服务器环境枚举
public enum Environment {
    ///官方正式版（代签包）
    case GM
    case appStore
    case testFlight
    case test
    case dev
    
    /// 获取对应环境的UrlEnvironmentModel  http://192.168.10.202:8861
    public func getUrlMode() -> UrlEnvironmentModel{
        switch self {
            case .appStore, .GM:
//                return UrlEnvironmentModel(httpDef: "https://",
//                                           host: "api.hailuo.pro",
//                                           port: "/")
                return UrlEnvironmentModel(httpDef: "https://",
                host: "api.0593xg.com",
                port: "/")
            case .testFlight:
//                return UrlEnvironmentModel(httpDef: "https://",
//                                           host: "api.hailuo.pro",
//                                           port: "/")
                return UrlEnvironmentModel(httpDef: "https://",
                host: "api.0593xg.com",
                port: "/")
            case .test: //测试线
                return UrlEnvironmentModel(httpDef: "http://",
                                           host: "hellotestzuul.lliao.net",
                                           port: ":8077/")
            case .dev:  //开发线
                return UrlEnvironmentModel(httpDef: "http://",
                                           host: "hellodevzuul.lliao.net",
                                           port: ":8077/")
        }
    }
    ///https://cdnfileapi.6xprog.com
    public func getFileUrlMode() -> UrlEnvironmentModel {
        switch self {
            case .appStore, .GM:
                return UrlEnvironmentModel(httpDef: "https://",
                                           host: "cdnfileapi.6xprog.com",
                                           port: "/")
            case .testFlight:
                return UrlEnvironmentModel(httpDef: "https://",
                                           host: "cdnfileapi.6xprog.com",
                                           port: "/")
            case .test: //测试线
                return UrlEnvironmentModel(httpDef: "http://",
                                           host: "testfileapi.6xprog.com",
                                           port: "/")
            case .dev:  //开发线
                return UrlEnvironmentModel(httpDef: "http://",
                                           host: "fileapi.lliao.net",
                                           port: ":8077/")
        }
    }
    
    public func getSignKeyAndIv() ->
        (kSignKey: String,
        kSecretKey: String,
        kBase64Key: String,
        kBase64Iv: String,
        kMessageBase64Key: String,
        kMessageBase64Iv: String,
        kFileSignKey: String,
        kFileSecretKey: String) {
            
            switch self {
            case .appStore, .GM:
                return ("Ioiwnfv2SBik3KiexebneioFE83sdz"
                    ,"uwien327bvEkbUEbna7933bnwefOue"
                    ,"RTKixjgV1bBv4VMGfcNMBA=="
                    ,"H3WXl4uct0UtgCboMWX/4w=="
                    ,"YzHihpFh8J+lpWninYBsdQ=="
                    ,"W2g7YcK3aeKAu2x177ybbw=="
                    ,"0A3DAD225E3EF804FBE3C5CA707E7B"
                    ,"47C637B0673CB3EDF84396F9CD3AB3")
            case .testFlight:
                return ("Ioiwnfv2SBik3KiexebneioFE83sdz"
                    ,"uwien327bvEkbUEbna7933bnwefOue"
                    ,"RTKixjgV1bBv4VMGfcNMBA=="
                    ,"H3WXl4uct0UtgCboMWX/4w=="
                    ,"YzHihpFh8J+lpWninYBsdQ=="
                    ,"W2g7YcK3aeKAu2x177ybbw=="
                    ,"0A3DAD225E3EF804FBE3C5CA707E7B"
                    ,"47C637B0673CB3EDF84396F9CD3AB3")
            case .test: //测试线
                return ("Ioiwnfv2SBik3KiexebneioFE83sdz"
                    ,"uwien327bvEkbUEbna7933bnwefOue"
                    ,"bowe3SoUembPHoiaSEsdfn=="
                    ,"MunsdVRkf8SXMeibueYyO0=="
                    ,"YzHihpFh8J+lpWninYBsdQ=="
                    ,"W2g7YcK3aeKAu2x177ybbw=="
                    ,"GiI96RYSSulSnDa3dlrNLAOK8Z6YE4"
                    ,"ndE2jdZNFixH9G6SSdsfyf7lYT3PxW")
            case .dev:  //开发线
                return ("Ioiwnfv2SBik3KiexebneioFE83sdz"
                    ,"uwien327bvEkbUEbna7933bnwefOue"
                    ,"bowe3SoUembPHoiaSEsdfn=="
                    ,"MunsdVRkf8SXMeibueYyO0=="
                    ,"YzHihpFh8J+lpWninYBsdQ=="
                    ,"W2g7YcK3aeKAu2x177ybbw=="
                    ,"GiI96RYSSulSnDa3dlrNLAOK8Z6YE4"
                    ,"ndE2jdZNFixH9G6SSdsfyf7lYT3PxW")
            }
    }
        
    // 【你的 access_key】
    public var awsAccessKey: String {
        switch self {
        case .appStore, .GM: return "AKIAJTOBIRSVAOMFMZBA"
        case .testFlight: return "AKIAJTOBIRSVAOMFMZBA"
        case .test: return "AKIAI3E2C6LQCRPVSMMQ"
        case .dev: return "AKIAI3E2C6LQCRPVSMMQ"
        }
    }
    // 【你的 aws_secret_key】
    public var awsSecretKey: String {
        switch self {
        case .appStore, .GM: return "3j9VGWpOhgW2pUnETT5OXr5vquY6eSUhMpV2ex0M"
        case .testFlight: return "3j9VGWpOhgW2pUnETT5OXr5vquY6eSUhMpV2ex0M"
        case .test: return "RBAZCJNoPjzFQXCJCqlx0mBc2qDmyKnrF3pxnCIP"
        case .dev:  return "RBAZCJNoPjzFQXCJCqlx0mBc2qDmyKnrF3pxnCIP"
        }
    }
    // 【你 bucket 的名字】 #注：首先需要保证 s3 上已经存在该存储桶;
    
    
    public var bucketName: String {
        
        switch self{
            case .appStore, .GM: return "static-hailuo-pro"
            case .testFlight: return "static-hailuo-pro"
            case .test: return "hello-file-test"
            case .dev:  return "hello-file-dev"
        }
    }
    // 原图桶名
    public var bucketNameOfImage: String {
        return self.bucketName
    }
    // 大图桶名
    public var bucketNameOfBigImage: String {
        return self.bucketName + "-big"
    }
    // 缩略图桶名
    public var bucketNameOfThumbImage: String {
        return self.bucketName + "-thumb"
    }
    
    public var endpoint: String {
        
        switch self{
            case .appStore, .GM: return "s3.ap-southeast-1.amazonaws.com"
            case .testFlight: return "s3.ap-southeast-1.amazonaws.com"
            case .test: return "s3.ap-east-1.amazonaws.com"
            case .dev:  return "s3.ap-east-1.amazonaws.com"
        }
    }

    
}


// 记录语言 zh_CN 中文简体，zh_TW 中文繁体,en_US 英文
public enum AppLocalEnum: String{
    case zh_CN, zh_TW, en_US
}


///每个环境对应的url配置
public struct UrlEnvironmentModel {
    
    public let httpDef: String
    public let host: String
    public let port: String
}
