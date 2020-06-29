//
//  ItemListTradingItem.swift
//  TelegramUI
//
//  Created by 黄国坚 on 2020/5/9.
//  Copyright © 2020 Telegram. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Display
import TelegramPresentationData
import Postbox

import Extension
import Language
import UI
import HL
import Then
import Model

///开通交易模块的cell
final class ItemListTradingItem: PeerInfoScreenItem{
    
    let id: AnyHashable
    let action: (ItemListTradingItemType) -> ()
    let peerId: PeerId
    let detail: BiluM.Group.Detail
    
    init(id: Int, peerId: PeerId, detail: BiluM.Group.Detail, action: @escaping (ItemListTradingItemType) -> ()){
        self.id = id
        self.peerId = peerId
        self.detail = detail
        self.action = action
    }
    
    func node() -> PeerInfoScreenItemNode{
        return ItemListTradingItemNode(detail: self.detail, chatId: "\(self.peerId.id)", onApply: self.action)
    }
}

private final class ItemListTradingItemNode: PeerInfoScreenItemNode{
    
    private lazy var tradingView: ItemListTradingItemNodeView = ItemListTradingItemNodeView.loadFromNib()
    
    init(detail: BiluM.Group.Detail, chatId: String, onApply: @escaping (ItemListTradingItemType)->()){
        
        super.init()
        
        self.setViewBlock { () -> UIView in
            return self.tradingView.then{
                
                $0.onApply = onApply
                $0.detail = detail
                $0.chatId = chatId
            }
        }
    }
    
    //返回高度
    override func update(width: CGFloat, presentationData: PresentationData, item: PeerInfoScreenItem, topItem: PeerInfoScreenItem?, bottomItem: PeerInfoScreenItem?, transition: ContainedViewLayoutTransition) -> CGFloat {
        guard let item = item as? ItemListTradingItem else {return 10.0}
        
        //背景颜色跟皮肤随动
        self.tradingView.backgroundColor = presentationData.theme.list.itemBlocksBackgroundColor
        
        return 80
    }
}
