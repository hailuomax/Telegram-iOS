//
//  ItemListTradingItem.swift
//  TelegramUI
//
//  Created by 黄国坚 on 2020/5/9.
//  Copyright © 2020 Telegram. All rights reserved.
//

import UIKit
import Display
import Postbox
import class SwiftSignalKit.Signal
import class SwiftSignalKit.Queue
import enum SwiftSignalKit.NoError
import TelegramPresentationData

import Then
import Model

public class ItemListTradingItem: ItemListItem{
    
    public let sectionId: ItemListSectionId
    let theme: PresentationTheme
    let action: (ItemListTradingItemType) -> ()
    let peerId: PeerId
    let detail: BiluM.Group.Detail
    public init(theme: PresentationTheme, sectionId: ItemListSectionId, peerId: PeerId, detail: BiluM.Group.Detail, action: @escaping (ItemListTradingItemType) -> ()){
        
        self.sectionId = sectionId
        self.theme = theme
        self.action = action
        self.peerId = peerId
        self.detail = detail
    }
}
//MARK： - istViewItem{
extension ItemListTradingItem: ListViewItem{
    
    //创建Node
    public func nodeConfiguredForParams(async: @escaping (@escaping () -> Void) -> Void, params: ListViewItemLayoutParams, synchronousLoads: Bool, previousItem: ListViewItem?, nextItem: ListViewItem?, completion: @escaping (ListViewItemNode, @escaping () -> (Signal<Void, NoError>?, (ListViewItemApply) -> Void)) -> Void) {
        
        async {
            let node = ItemListTradingItemNode(theme: self.theme, detail: self.detail, chatId: "\(self.peerId.id)", onApply: self.action)
            let (layout, apply) = node.asyncLayout()(self, params, itemListNeighbors(item: self, topItem: previousItem as? ItemListItem, bottomItem: nextItem as? ItemListItem))
            
            node.contentSize = layout.contentSize
            node.insets = layout.insets
            
            Queue.mainQueue().async {
                completion(node, {
                    return (nil, { _ in apply() })
                })
            }
        }
    }
    // 更新Node方法
    public func updateNode(async: @escaping (@escaping () -> Void) -> Void, node: @escaping () -> ListViewItemNode, params: ListViewItemLayoutParams, previousItem: ListViewItem?, nextItem: ListViewItem?, animation: ListViewItemUpdateAnimation, completion: @escaping (ListViewItemNodeLayout, @escaping (ListViewItemApply) -> Void) -> Void) {
        
    }
}




public class ItemListTradingItemNode: ListViewItemNode, ItemListItemNode{
    public var tag: ItemListItemTag?
    init(theme: PresentationTheme, detail: BiluM.Group.Detail, chatId: String, onApply: @escaping (ItemListTradingItemType)->()){
        super.init(layerBacked: false, dynamicBounce: false)
        
        self.setViewBlock { () -> UIView in
            return ItemListTradingItemNodeView.loadFromNib().then{
                //背景颜色跟皮肤随动
                $0.backgroundColor = theme.list.itemBlocksBackgroundColor
                $0.onApply = onApply
                $0.detail = detail
                $0.chatId = chatId
            }
        }
        
        
    }
}

extension ItemListTradingItemNode {
    
    ///设置Node约束
    func asyncLayout() -> (_ item: ItemListTradingItem, _ params: ListViewItemLayoutParams, _ neighbors: ItemListNeighbors) -> (ListViewItemNodeLayout, () -> Void) {
        
        return { item , params, neighbors in
            
            //自身的高度
            var itemNodeLayout = ListViewItemNodeLayout(contentSize: CGSize(width: params.width, height: 80), insets: .zero)
            return (itemNodeLayout, {})
        }
    }
}
