//
//  ChatMsgConfig.swift 解析聊天内容转换成红包的相关配置
//  HL
//
//  Created by 黄国坚 on 2020/3/23.
//

import Foundation

//解析聊天内容转换成红包的相关配置
struct ChatMsgConfig{
    
    ///V0版本的前缀识别
    struct V0{
        static let RedPacket = "海螺红包"
        static let Transfer = "海螺转账"
        static let Exchange = "海螺闪兑"
    }
    
    ///V1的前缀识别
    struct V1{
        static let RedPacket: String = Heart + "下载海螺 APP，体验红包新功能" + Heart
        static let Transfer: String =  Heart + "下载海螺 APP，体验红包新功能" + Heart
        static let Exchange: String = Heart + "下载海螺 APP，体验红包新功能" + Heart
        ///红心分隔符
        static let Heart: String = "♥"
        ///当前识别前缀的规则版本号
        static let version: Int = 1
    }
}
