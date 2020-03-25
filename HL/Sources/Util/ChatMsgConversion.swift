//
//  ChatMsgConversion.swift
//  HL
//
//  Created by 黄国坚 on 2020/3/23.
//

import Foundation
import CryptoSwift

/// 聊天交易相关的气泡类型
public enum ChatMsgEnum {
    
    //不明类型
    case unknow(type: String)
    ///红包(version: 版本号, type: 气泡类型, id: 红包id, senderId: 发送人id, recipientId: 接收人id, remark: 备注)
    case redPacket(version: Int, type: String, id: String, senderId: String, recipientId: String, remark: String)
    ///转账(version: 版本号, type: 气泡类型, id: 转账id, senderId: 发送人id, recipientId: 接收人id, remark: 备注)
    case transfer(version: Int, type: String, id: String, senderId: String, recipientId: String, remark: String)
    ///闪兑(version: 版本号, type: 气泡类型, id: 转账id, senderId: 发送人id, recipientId: 接收人id, , payCoin: 支付币种, getCoin: 兑换获得的币种)
    case exchange(version: Int, type: String, id: String, senderId: String, recipientId: String, payCoin: String, getCoin: String)
    
    
    /// 聊天列表的显示文本
    public func listTitle() -> String{
        switch self {
        case .redPacket: return HL.Language.RedPacket.str
        case .transfer: return HL.Language.Transfer.str
        case .exchange: return HL.Language.FastExchange.str
        @unknown default: return "不明类型"
        }
    }
    
    /// 生成完整的聊天加密内容
    public func generateChatMsg() -> String{
        
        let bodyStr = generateBodyStr()
        
        //清前后空格和换行
        func checkRemark(_ remark: String, placeHolder: String) -> String{
            let remark = remark.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            return remark.isEmpty ? placeHolder : remark
        }
        
        //备注
        let remark: String = {
            switch self {
            case .unknow:
                return ""
            case .redPacket(_, _, _, _, _, let remark):
                return checkRemark(remark, placeHolder: HL.Language.Congratulations.str)
            case .transfer(_, _, _, _, _, let remark):
                return checkRemark(remark, placeHolder: HL.Language.Transfer.messageTip.str)
            case .exchange(let version, let type, let id, let senderId, let recipientId, let payCoin, let getCoin):
                return payCoin + HL.Language.Exchange.str + getCoin
            @unknown default:
                return ""
            }
        }()
        
        var msgStr = ""
        ["【",
         ChatMsgConfig.V1.RedPacket,
            remark,
            ChatMsgConfig.V1.Heart,
            bodyStr.jy.base64Encoding(), //base64加密
            ChatMsgConfig.V1.Heart,
            md5TransactionInfos(bodyStr, remark: remark), //md5加密
            ChatMsgConfig.V1.Heart,
            "】"].forEach{msgStr += $0}
        
        return msgStr
        
    }
    
    /// 生成的body内容
    private func generateBodyStr() -> String{
        switch self {
        
        case .unknow(let type):
            return ""
        case .redPacket(let version, let type, let id, let senderId, let recipientId, _),
            .transfer(let version, let type, let id, let senderId, let recipientId, _):
            return "\(version)-\(type)-\(id)-\(senderId)-\(recipientId)"
        case .exchange(let version, let type, let id, let senderId, let recipientId, let payCoin, let getCoin):
            return "\(version)-\(type)-\(id)-\(senderId)-\(recipientId)-\(payCoin)-\(getCoin)"
        @unknown default:
            return ""
        }
    }
}

/// 聊天内容转换工具，用于转换显示红包气泡等
public struct ChatMsgConversion {
    
}

extension ChatMsgConversion: InputOutputStype{
    
    typealias Input = String
    
    typealias Output = ChatMsgEnum
    
    public func transform(input: String) -> ChatMsgEnum {
        return ChatMsgEnum.unknow(type: "0")
    }
}

extension ChatMsgConversion {
 
    
    ///会话列表解析V1的红包
    private func decodeV1(_ messageStr: String) -> ChatMsgEnum? {
        
        let infos = messageStr.components(separatedBy: ChatMsgConfig.V1.Heart)
        
        //【♥下载海螺 APP，体验红包新功能♥恭喜發財，大吉大利♥MS0xLTEyMzI1OTczMzMxODEwNjMxNzAtODc3MDM1ODI3LTg3NzAzNTgyNw==♥A930037540F7FDB11C3367601540D868♥】
        guard infos.count == 6 else {return nil}
        
        //base64与md5校验
        let strFromBase64: String = infos[3].jy.base64Decoding() ?? ""
        let remark = infos[2]
        
        let finalMd5Str = md5TransactionInfos(strFromBase64, remark: remark)
        guard finalMd5Str == infos[4] else {return nil}
        
        print(infos)
        
        var transactionInfos = strFromBase64.components(separatedBy: "-")
        if transactionInfos[0] != "\(ChatMsgConfig.V1.version)" { //版本号不对,后续数据都为空
            transactionInfos = transactionInfos.enumerated().compactMap({
                return ($0 == 0 || $0 == 1) ? $1 : ""
            })
        }
        print(transactionInfos)
        
        switch transactionInfos[1] {
        case "1":
            guard transactionInfos.count >= 4 else {return nil}
            return .redPacket(version: ChatMsgConfig.V1.version, type: "1", id: transactionInfos[1], senderId: transactionInfos[2], recipientId: transactionInfos[3], remark: remark)
        case "2":
            guard transactionInfos.count >= 4 else {return nil}
            return .transfer(version: ChatMsgConfig.V1.version, type: "2", id: transactionInfos[1], senderId: transactionInfos[2], recipientId: transactionInfos[3], remark: remark)
        case "3":
            guard transactionInfos.count >= 6 else {return nil}
            return .exchange(version: ChatMsgConfig.V1.version, type: "3", id: transactionInfos[1], senderId: transactionInfos[2], recipientId: transactionInfos[3], payCoin: transactionInfos[4], getCoin: transactionInfos[5])
        default:
            return nil
        }
        
    }
}

///md5交易信息
fileprivate func md5TransactionInfos(_ str: String, remark: String) -> String{
    let md5Str = str + remark
    let messageBase64Key: String = APPConfig.environment.getSignKeyAndIv().kMessageBase64Key
    return (md5Str.md5().uppercased() + (messageBase64Key.jy.base64Decoding())).md5().uppercased()
}

public enum MyError: Error {
    case modelError
}
