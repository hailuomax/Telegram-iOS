//
//  Peer+Extension.swift
//  TelegramUI
//
//  Created by 黄国坚 on 2020/5/19.
//  Copyright © 2020 Telegram. All rights reserved.
//

import Foundation
import Postbox

extension Peer{
    
    ///判断是否是绑定了频道的群,而且是拥有者
    public func isChannelGroupCreater() -> Bool{
        guard let peer = self as? TelegramChannel else {return false}
        if case .group = peer.info, peer.flags == .isCreator {
            return true
        }else {
            return false
        }
    }
    ///判断是否是普通群的拥有者
    public func isGroupCreater() -> Bool{
        guard let peer = self as? TelegramGroup else {return false}
        switch peer.role{
        case .creator:
            return true
        case .admin,
             .member:
            return false
        }
    }
    ///是群或者着频道绑定的群
    public func isGroupOrChannelGroup() -> Bool{
        if self is TelegramGroup {return true}
        if let peer = self as? TelegramChannel, case .group = peer.info {return true}
        
        return false
    }
}
