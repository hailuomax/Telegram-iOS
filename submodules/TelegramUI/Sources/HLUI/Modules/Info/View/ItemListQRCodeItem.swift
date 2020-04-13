//
//  QRCodeItem.swift
//  TelegramUI
//
//  Created by lemon on 2020/3/5.
//  Copyright © 2020 Telegram. All rights reserved.
//

import Foundation
import UIKit
import Display
import AsyncDisplayKit
import Postbox
import TelegramCore
import SwiftSignalKit
import TelegramPresentationData
import class SwiftSignalKit.Signal
import class SwiftSignalKit.Timer
import class SwiftSignalKit.Bag
import class SwiftSignalKit.Queue
import enum SwiftSignalKit.NoError
import ItemListUI

enum ItemListQRCodeItemType {
    case user
    case group
}


class ItemListQRCodeItem :  ListViewItem, ItemListItem {
    
    let theme: PresentationTheme
    let sectionId: ItemListSectionId
    let style: ItemListStyle
    let title: String
    let action: (() -> Void)?
    let clearHighlightAutomatically: Bool
    let type :  ItemListQRCodeItemType
    
    init(theme: PresentationTheme ,sectionId: ItemListSectionId, title: String ,type : ItemListQRCodeItemType ,style : ItemListStyle , action:(() -> Void)?, clearHighlightAutomatically: Bool = true ) {
        self.theme = theme
        self.sectionId = sectionId
        self.style = style
        self.action = action
        self.title = title
        self.type = type
        
        self.clearHighlightAutomatically = clearHighlightAutomatically
    }
    
    //MARK: -- 创建Node
    func nodeConfiguredForParams(async: @escaping (@escaping () -> Void) -> Void, params: ListViewItemLayoutParams, synchronousLoads: Bool, previousItem: ListViewItem?, nextItem: ListViewItem?, completion: @escaping (ListViewItemNode, @escaping () -> (Signal<Void, NoError>?, (ListViewItemApply) -> Void)) -> Void) {
        
        async {
            let node = ItemListQRCodeItemNode()
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
    
    //MARK: -- 更新Node方法
    func updateNode(async: @escaping (@escaping () -> Void) -> Void, node: @escaping () -> ListViewItemNode, params: ListViewItemLayoutParams, previousItem: ListViewItem?, nextItem: ListViewItem?, animation: ListViewItemUpdateAnimation, completion: @escaping (ListViewItemNodeLayout, @escaping (ListViewItemApply) -> Void) -> Void) {
        
        Queue.mainQueue().async {
            
            if let nodeValue = node() as? ItemListQRCodeItemNode {
                let makeLayout = nodeValue.asyncLayout()
                
                async {
                    let (layout , apply) = makeLayout(self, params ,itemListNeighbors(item: self, topItem: previousItem as? ItemListItem, bottomItem: nextItem as? ItemListItem))
                    
                    Queue.mainQueue().async {
                        completion(layout, { _ in
                            apply()
                        })
                    }
                }
            }
            
        }
        
    }
    
    
    //MARK: -- 点击node方法
    var selectable: Bool = true
    func selected(listView: ListView){
        //
        if self.clearHighlightAutomatically {
            listView.clearHighlightAnimated(true)
        }
        action?()
    }
    
}

private let titleFont = Font.regular(17.0)

class ItemListQRCodeItemNode : ListViewItemNode , ItemListItemNode {
    /// 背景node
    private let backgroundNode: ASDisplayNode
    /// 上实线
    private let topStripeNode: ASDisplayNode
    /// 下实线
    private let bottomStripeNode: ASDisplayNode
    /// 高亮背景
    private let highlightedBackgroundNode: ASDisplayNode
    
    private let codeNode : ASImageNode
    
    let titleNode : TextNode
    
    let arrowNode: ASImageNode
    
    var tag: ItemListItemTag?
    
    private var item: ItemListQRCodeItem?
    
    
    init(){
        self.backgroundNode = ASDisplayNode()
        self.backgroundNode.isLayerBacked = true
        self.backgroundNode.backgroundColor = .white
        
        self.topStripeNode = ASDisplayNode()
        self.topStripeNode.isLayerBacked = true
        
        self.bottomStripeNode = ASDisplayNode()
        self.bottomStripeNode.isLayerBacked = true
        
        self.highlightedBackgroundNode = ASDisplayNode()
        self.highlightedBackgroundNode.isLayerBacked = true
        
        self.titleNode = TextNode()
        self.titleNode.isUserInteractionEnabled = false
        
        self.arrowNode = ASImageNode()
        self.arrowNode.displayWithoutProcessing = true
        self.arrowNode.displaysAsynchronously = false
        self.arrowNode.isLayerBacked = true
        
        self.codeNode = ASImageNode()
        self.codeNode.displayWithoutProcessing = true
        self.codeNode.displaysAsynchronously = false
        self.codeNode.isLayerBacked = true
        
        super.init(layerBacked: false, dynamicBounce: false)
        
        self.addSubnode(self.titleNode)
        self.addSubnode(self.arrowNode)
        self.addSubnode(self.codeNode)
        
    }
    
    //MARK: -- 设置Node约束
    func asyncLayout() -> (_ item: ItemListQRCodeItem, _ params: ListViewItemLayoutParams, _ neighbors: ItemListNeighbors) -> (ListViewItemNodeLayout, () -> Void) {
        
        let makeTitleLayout = TextNode.asyncLayout(self.titleNode)
        
        let currentItem = self.item
        
        return { item , params, neighbors in
            
            //初始化需要的颜色，需要的宽高，间距等
            var updateArrowImage: UIImage?
            
            var updatedTheme: PresentationTheme?
            if currentItem?.theme !== item.theme {
                updatedTheme = item.theme
                updateArrowImage = PresentationResourcesItemList.disclosureArrowImage(item.theme)
            }
            
            let separatorHeight = UIScreenPixel
            let itemBackgroundColor: UIColor
            let itemSeparatorColor: UIColor
            let leftInset = 16.0 + params.leftInset
            
            switch item.style {
            case .plain:
                itemBackgroundColor = item.theme.list.plainBackgroundColor
                itemSeparatorColor = item.theme.list.itemPlainSeparatorColor
                
            case .blocks:
                itemBackgroundColor = item.theme.list.itemBlocksBackgroundColor
                itemSeparatorColor = item.theme.list.itemBlocksSeparatorColor
            }
            
            let titleColor = item.theme.list.itemPrimaryTextColor
            let (titleLayout, titleApply) = makeTitleLayout(TextNodeLayoutArguments(attributedString: NSAttributedString(string: item.title, font: titleFont, textColor: titleColor), backgroundColor: nil, maximumNumberOfLines: 1, truncationType: .end, constrainedSize: CGSize(width: params.width - params.rightInset - 20.0 - leftInset, height: CGFloat.greatestFiniteMagnitude), alignment: .natural, cutout: nil, insets: UIEdgeInsets()))
            
            let insets = itemListNeighborsPlainInsets(neighbors)
            //Noded的Size
            let height : CGFloat = 44
            let contentSize = CGSize(width: params.width, height: height)
            let nodeLayout = ListViewItemNodeLayout(contentSize: contentSize, insets: insets)
            
            return (nodeLayout , { [weak self]  in
                if let strongSelf = self {
                    // 设置item时机
                    strongSelf.item = item
                    // 主题更新
                    if let _ = updatedTheme {
                        strongSelf.topStripeNode.backgroundColor = itemSeparatorColor
                        strongSelf.bottomStripeNode.backgroundColor = itemSeparatorColor
                        strongSelf.backgroundNode.backgroundColor = itemBackgroundColor
                        strongSelf.highlightedBackgroundNode.backgroundColor = item.theme.list.itemHighlightedBackgroundColor
                    }
                    
                    if let updateArrowImage = updateArrowImage {
                        strongSelf.arrowNode.image = updateArrowImage
                    }
                    
                    let _ = titleApply()
                    
                    // 设置是否显示上下线
                    switch item.style {
                    case .plain:
                        if strongSelf.backgroundNode.supernode != nil {
                            strongSelf.backgroundNode.removeFromSupernode()
                        }
                        if strongSelf.topStripeNode.supernode != nil {
                            strongSelf.topStripeNode.removeFromSupernode()
                        }
                        if strongSelf.bottomStripeNode.supernode == nil {
                            strongSelf.insertSubnode(strongSelf.bottomStripeNode, at: 0)
                        }
                        
                        strongSelf.bottomStripeNode.frame = CGRect(origin: CGPoint(x: leftInset, y: contentSize.height - separatorHeight), size: CGSize(width: params.width - leftInset, height: separatorHeight))
                    case .blocks:
                        if strongSelf.backgroundNode.supernode == nil {
                            strongSelf.insertSubnode(strongSelf.backgroundNode, at: 0)
                        }
                        if strongSelf.topStripeNode.supernode == nil {
                            strongSelf.insertSubnode(strongSelf.topStripeNode, at: 1)
                        }
                        if strongSelf.bottomStripeNode.supernode == nil {
                            strongSelf.insertSubnode(strongSelf.bottomStripeNode, at: 2)
                        }
                        switch neighbors.top {
                        case .sameSection(false):
                            strongSelf.topStripeNode.isHidden = true
                        default:
                            strongSelf.topStripeNode.isHidden = false
                        }
                        let bottomStripeInset: CGFloat
                        switch neighbors.bottom {
                        case .sameSection(false):
                            bottomStripeInset = leftInset
                        default:
                            bottomStripeInset = 0.0
                        }
                        
                        strongSelf.backgroundNode.frame = CGRect(origin: CGPoint(x: 0.0, y: -min(insets.top, separatorHeight)), size: CGSize(width: params.width, height: contentSize.height + min(insets.top, separatorHeight) + min(insets.bottom, separatorHeight)))
                        strongSelf.topStripeNode.frame = CGRect(origin: CGPoint(x: 0.0, y: -min(insets.top, separatorHeight)), size: CGSize(width: params.width, height: separatorHeight))
                        strongSelf.bottomStripeNode.frame = CGRect(origin: CGPoint(x: bottomStripeInset, y: contentSize.height - separatorHeight), size: CGSize(width: params.width - bottomStripeInset, height: separatorHeight))
                    }
                    
                    strongSelf.titleNode.frame = CGRect(origin: CGPoint(x: leftInset, y: 11.0), size: titleLayout.size)
                    
//                    strongSelf.codeNode.image = PresentationResourcesSettings.groupQRCode
                    
                    if let arrowImage = strongSelf.arrowNode.image {
                        strongSelf.arrowNode.frame = CGRect(origin: CGPoint(x: params.width - params.rightInset - 15.0 - arrowImage.size.width, y: floorToScreenPixels((height - arrowImage.size.height) / 2.0)), size: arrowImage.size)
                    }
                    
                    
                    strongSelf.codeNode.frame = CGRect(origin: CGPoint(x: params.width - params.rightInset - 60, y: floorToScreenPixels((height - 20) / 2.0)), size: CGSize(width: 20, height: 20))
                    
                    
                }
                
                
                
            })
        }
        
    }
    
}
