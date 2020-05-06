//
//  TelegramMediaExchange.swift
//  TelegramUI#shared
//
//  Created by lemon on 2020/5/6.
//

import Postbox
import SyncCore
import Language

/// 闪兑消息
public final class TelegramMediaExchange : Media{
    
    public let exchangeId: String
    /// 发送人id
    public let senderId: String
    /// 兑入
    public let inCoin: String
    /// 兑出
    public let outCoin: String
    /// 组装的汇率str
    public let rateStr: String?
    
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
        self.exchangeId = decoder.decodeStringForKey("exchangeId", orElse: "0")
        self.senderId = decoder.decodeStringForKey("senderId", orElse: "")
        self.inCoin = decoder.decodeStringForKey("inCoin", orElse: "")
        self.outCoin = decoder.decodeStringForKey("outCoin", orElse: "")
        self.rateStr = decoder.decodeStringForKey("rateStr", orElse: "")
    }
    
    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeString(self.exchangeId, forKey: "exchangeId")
        encoder.encodeString(self.senderId, forKey: "senderId")
        encoder.encodeString(self.inCoin, forKey: "inCoin")
        encoder.encodeString(self.outCoin, forKey: "outCoin")
        encoder.encodeString(self.rateStr ?? "", forKey: "rateStr")
    }
        
    /// 构造
    public init(exchangeId: String,senderId: String, inCoin: String ,outCoin :String, rateStr: String?){
        self.exchangeId = exchangeId
        self.senderId = senderId
        self.inCoin = inCoin
        self.outCoin = outCoin
        self.rateStr = rateStr
    }

}
