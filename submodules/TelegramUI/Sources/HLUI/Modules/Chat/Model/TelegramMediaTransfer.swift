//
//  TelegramMediaTransfer.swift
//  TelegramUI#shared
//
//  Created by lemon on 2020/4/30.
//

import Postbox
import SyncCore
import Language

/// 转账消息体
public final class TelegramMediaTransfer : Media{
    
    public let transferId: String
    /// 币种类型
    public let senderId: String
    /// 红包金额
    public let remark: String
    
    public let receiveStatus: Int
    
    //MARK: - Media protocol
    public let id: MediaId? = nil
    
    public let peerIds: [PeerId] = []
    
    public func isEqual(to other: Media) -> Bool {
        return false
    }
    
    public func isSemanticallyEqual(to other: Media) -> Bool {
        return isEqual(to: other)
    }
    
    public init(decoder: PostboxDecoder) {
        self.transferId = decoder.decodeStringForKey("transferId", orElse: "0")
        self.senderId = decoder.decodeStringForKey("senderId", orElse: "")
        self.remark = decoder.decodeStringForKey("remark", orElse: HLLanguage.Congratulations.localized())
        self.receiveStatus = Int(decoder.decodeInt32ForKey("receiveStatus", orElse: 0))
    }
    
    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeString(self.transferId, forKey: "transferId")
        encoder.encodeString(self.senderId, forKey: "senderId")
        encoder.encodeString(self.remark, forKey: "remark")
        encoder.encodeInt32(Int32(self.receiveStatus), forKey: "receiveStatus")
    }
    
    /// 构造
    public init(transferId: String,senderId: String, remark: String,_ receiveStatus: Int = 0){
        self.transferId = transferId
        self.senderId = senderId
        self.remark = remark
        self.receiveStatus = receiveStatus
    }
}
