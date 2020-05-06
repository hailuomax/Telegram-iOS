//
//  AnalyseMessageUtil.swift
//  TelegramUI#shared
//
//  Created by lemon on 2020/4/30.
//

import Foundation
import HL
import Postbox

class AnalyseMessageUtil {
    //-> ChatMessageBubbleItemNode -> contentNodeMessagesAndClassesForItem
    /// 解析新版消息
    class V1 {
        static func analyse(message: Message) ->( Message, ChatMessageBubbleContentNode.Type ){
            switch ChatMsgConversion.default.transform(input:message.text) {
                
            case .redPacket(version: let version, type: let type, id: let id, senderId: let senderId, recipientId: let recipientId, remark: let remark):
                let redPacket = TelegramMediaRedPackets(redPacketId: id, senderId: senderId, remark: remark,message.receiveStatus)
                
                return (message.withUpdatedMedia([redPacket]), ChatMessageRedPacketBubbleContentNode.self)
            case .transfer(version: let version, type: let type, id: let id, senderId: let senderId, recipientId: let recipientId, remark: let remark):
                let transfer = TelegramMediaTransfer(transferId: id, senderId: senderId, remark: remark,message.receiveStatus)
                return (message.withUpdatedMedia([transfer]), ChatMessageTransferBubbleContentNode.self)
            case .exchange(version: let version, type: let type, id: let id, senderId: let senderId, recipientId: let recipientId, payCoin: let payCoin, getCoin: let getCoin):
                var rateStr: String?
                
                //不需要显示汇率，代码暂时注释
                //            if transactionInfos.count >= 8{
                //                rateStr = transactionInfos[7]
                //            }
                let exchange = TelegramMediaExchange(exchangeId: id,senderId: senderId, inCoin: transactionInfos[6] ,outCoin: transactionInfos[5], rateStr: rateStr)
                guard transactionInfos.count > 6 else {
                    return (message, ChatMessageTextBubbleContentNode.self)
                }
                
            default:
                return (message, ChatMessageTextBubbleContentNode.self)
                
            }
        }
    }
    
    /// 解析旧版消息
    class V0 {
        
    }
    
}
