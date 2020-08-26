//
//  AnalyseMessageUtil.swift
//  TelegramUI#shared
//
//  Created by lemon on 2020/4/30.
//

import Foundation
import HL
import Postbox
import Config
import CryptoSwift
import Extension
import Model
import Account

class AnalyseMessageUtil {
    //-> ChatMessageBubbleItemNode -> contentNodeMessagesAndClassesForItem
    /// 解析新版消息
    class V1 {
        static func analyse(message: Message) ->( Message, ChatMessageBubbleContentNode.Type ){
            
            //备注分析是清除 邀请链接
            func handelRemark(_ r: String) -> String{
                let strAry: [String] = r.components(separatedBy: " ")
                guard let replaceStr: String = strAry.last(where: {!$0.isEmpty}) else {return r}
                
                return r.replacingOccurrences(of: replaceStr, with: "")
            }
            
            switch ChatMsgConversion.default.transform(input:message.text) {
                
            case .redPacket(version: let version, type: let type, id: let id, senderId: let senderId, recipientId: let recipientId, remark: let remark):
                
                let remark = handelRemark(remark)
                
                let redPacket = TelegramMediaRedPackets(redPacketId: id, senderId: senderId, remark: remark, message.receiveStatus)
                
                return (message.withUpdatedMedia([redPacket]), ChatMessageRedPacketBubbleContentNode.self)
            case .transfer(version: let version, type: let type, id: let id, senderId: let senderId, recipientId: let recipientId, remark: let remark):
                
                let remark = handelRemark(remark)
                
                let transfer = TelegramMediaTransfer(transferId: id, senderId: senderId, remark: remark, message.receiveStatus)
                return (message.withUpdatedMedia([transfer]), ChatMessageTransferBubbleContentNode.self)
            case .exchange(version: let version, type: let type, id: let id, senderId: let senderId, recipientId: let recipientId, payCoin: let payCoin, getCoin: let getCoin):
                var rateStr: String?
                

                let exchange = TelegramMediaExchange(exchangeId: id,senderId: senderId, inCoin: payCoin ,outCoin: getCoin, rateStr: rateStr)
                
                return  (message.withUpdatedMedia([exchange]), ChatMessageExchangeBubbleContentNode.self)
            default:
                return (message, ChatMessageTextBubbleContentNode.self)
                
            }
        }
    }
    
    /// 解析旧版消息
    class V0 {
        //旧红包解析
        //在这里要拿到text文本的值，判断是否可转换成红包的模型，假如可以，不插入文本，组装红包的message
        
        static func analyse(message: Message) ->( Message, ChatMessageBubbleContentNode.Type ){
            let encryStr = message.text.replacingOccurrences(of: ChatMsgConfig.V0.RedPacket, with: "")
                .replacingOccurrences(of: ChatMsgConfig.V0.Transfer, with: "")
                .replacingOccurrences(of: ChatMsgConfig.V0.Exchange, with: "")
            
            let messageBase64Key: String = APPConfig.environment.getSignKeyAndIv().kMessageBase64Key
            let messageBase64Iv: String = APPConfig.environment.getSignKeyAndIv().kMessageBase64Iv
            
            if let encryBase64 = Data(base64Encoded: encryStr) {
                do {
                    let decrypted = try AES(key: messageBase64Key.jy.base64Data(), blockMode: CBC(iv: messageBase64Iv.jy.base64Data()),padding: .pkcs7).decrypt([UInt8](encryBase64))
                    let messageTypeData: Data = Data(bytes: decrypted, count: decrypted.count)
                    let messageTypeStr = String(data: messageTypeData, encoding: .utf8) ?? ""
                    print("messageTypeStr---->\(messageTypeStr)")
                    guard let messageTypeModel = messageTypeStr.jy.toModel(MessageTypeModel.self) else {
                        throw MyError.modelError
                    }
                    let dataStr = messageTypeModel.data
                    let type = Int(messageTypeModel.type) ?? 0
                    switch type {
                    case 1:
                        guard let messageRedPacketModel = dataStr.jy.toModel(MessageRedPacketModel.self) else {
                            throw MyError.modelError
                        }
                        let redPacket = TelegramMediaRedPackets(redPacketId: messageRedPacketModel.id, senderId: messageRedPacketModel.senderId, remark: messageRedPacketModel.remark)
                        let messageNew = message.withUpdatedMedia([redPacket])
                        return (messageNew, ChatMessageRedPacketBubbleContentNode.self)
                    case 2:
                        guard let messageTransferModel = dataStr.jy.toModel(MessageTransferModel.self) else {
                            throw MyError.modelError
                        }
                        let transfer = TelegramMediaTransfer(transferId: messageTransferModel.id, senderId: messageTransferModel.senderId, remark: messageTransferModel.remark)
                        let messageNew = message.withUpdatedMedia([transfer])
                        return (messageNew, ChatMessageTransferBubbleContentNode.self)
                    case 3:
                        guard let messageExchangeModel = dataStr.jy.toModel(MessageExchangeModel.self) else {
                            throw MyError.modelError
                        }
                        let exchange = TelegramMediaExchange(exchangeId: messageExchangeModel.id,senderId: messageExchangeModel.senderId, inCoin: messageExchangeModel.inCoin ,outCoin :messageExchangeModel.outCoin, rateStr: nil)
                        let messageNew = message.withUpdatedMedia([exchange])
                        return (messageNew, ChatMessageExchangeBubbleContentNode.self)
                    default:
                        return (message, ChatMessageTextBubbleContentNode.self)
                    }
                    //将字符串转换成MessageTypeModel{type,data,version}
                    //获取data的值，根据type，将对应data的值转换为对应的model
                    //更新对应的model
                } catch _ {
                    return (message, ChatMessageTextBubbleContentNode.self)
                }
            } else {
                return (message, ChatMessageTextBubbleContentNode.self)
            }
        }
       
                       
    }
    
}
