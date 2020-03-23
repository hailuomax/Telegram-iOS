//
//  ChatMsgConversion.swift
//  HL
//
//  Created by 黄国坚 on 2020/3/23.
//

import Foundation


/// 聊天内容转换出来的气泡类型
public enum ChatMsgEnum: String, Codable{
    
    ///红包
    case redPacket = "1"
    ///转账
    case transfer = "2"
    ///闪兑
    case exchange = "3"
    
    
    /// 气泡的标题
    public func title() -> String{
        switch self {
        case .redPacket: return HL.Language.RedPacket.str
        case .transfer: return HL.Language.Transfer.str
        case .exchange: return HL.Language.FastExchange.str
        @unknown default: return "不明类型"
        }
    }
}

/// 聊天内容转换工具，用于转换显示红包气泡等
public struct ChatMsgConversion {
    
}

extension ChatMsgConversion: InputOutputStype{
    
    typealias Input = String
    
    typealias Output = String
    
    func transform(input: String) -> String {
        return ""
    }
}
