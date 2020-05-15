//
//  QRCodeItem.swift
//  TelegramUI
//
//  Created by lemon on 2020/3/5.
//  Copyright © 2020 Telegram. All rights reserved.
//
import Foundation
import AsyncDisplayKit
import Display
import TelegramPresentationData

import Extension
import Language
import UI
import HL

final class PeerInfoScreenQrCodeItem: PeerInfoScreenItem {
    
    let id: AnyHashable
    
    let action: (() -> Void)?
    
    // 输入需要的属性
    init(id: AnyHashable ,  action: (() -> Void)?) {
        self.id = id
        self.action = action
    }
    
    func node() -> PeerInfoScreenItemNode {
        return PeerInfoScreenQrCodeItemNode()
    }
}

private final class PeerInfoScreenQrCodeItemNode : PeerInfoScreenItemNode {
    
    private let selectionNode: PeerInfoScreenSelectableBackgroundNode
    
    private let textNode: ImmediateTextNode
    
    private let codeNode : ASImageNode
    
    private let arrowNode: ASImageNode
    
    private let bottomSeparatorNode: ASDisplayNode
    
    override init(){
        var bringToFrontForHighlightImpl: (() -> Void)?
        self.selectionNode = PeerInfoScreenSelectableBackgroundNode(bringToFrontForHighlight: { bringToFrontForHighlightImpl?() })
        self.textNode = ImmediateTextNode()
        self.textNode.displaysAsynchronously = false
        self.textNode.isUserInteractionEnabled = false
        
        self.arrowNode = ASImageNode()
        self.codeNode = ASImageNode()
        self.bottomSeparatorNode = ASDisplayNode()
        self.bottomSeparatorNode.isLayerBacked = true
        
        self.arrowNode.isUserInteractionEnabled = false
        self.codeNode.isUserInteractionEnabled = false
        
        super.init()
        self.addSubnode(self.textNode)
        self.addSubnode(self.arrowNode)
        self.addSubnode(self.codeNode)
        self.addSubnode(self.selectionNode)
        self.addSubnode(self.bottomSeparatorNode)
        bringToFrontForHighlightImpl = { [weak self] in
            self?.bringToFrontForHighlight?()
        }
    }
    
    override func update(width: CGFloat, presentationData: PresentationData, item: PeerInfoScreenItem, topItem: PeerInfoScreenItem?, bottomItem: PeerInfoScreenItem?, transition: ContainedViewLayoutTransition) -> CGFloat {
        
        guard let item = item as? PeerInfoScreenQrCodeItem else {
            return 10.0
        }
        self.selectionNode.pressed = item.action
        
        let sideInset: CGFloat = 16.0
        let verticalInset: CGFloat = 7.0
        self.textNode.attributedText = NSAttributedString(string: HLLanguage.GroupQRCodeTitle.localized(), font: Font.regular(16.0), textColor: presentationData.theme.list.itemPrimaryTextColor)
        
        let textSize = self.textNode.updateLayout(CGSize(width: width - sideInset * 2.0, height: .greatestFiniteMagnitude))
        
        let height : CGFloat = 50
        
        let textFrame = CGRect(origin: CGPoint(x: sideInset, y: (height - textSize.height) / 2), size: textSize)
        
        transition.updateFrame(node: self.textNode, frame: textFrame)
        
        let arrowImage = PresentationResourcesItemList.disclosureArrowImage(presentationData.theme)
        let codeImage = UIImage(bundleImageName: "GroupQRCode")
        
        //箭头图片
        var codeX = width
        if let arrowSize = arrowImage?.size {
            arrowNode.image = arrowImage
            let arrowFrame = CGRect(x: width - sideInset - arrowSize.width,  y: (height - arrowSize.height) / 2, width:arrowSize.width, height:arrowSize.height)
            transition.updateFrame(node: arrowNode, frame:  arrowFrame)
            codeX =  arrowFrame.minX - 5
        }
        // 二维码图片
        if let codeSize = codeImage?.size {
            codeNode.image = codeImage
            let codeFrame = CGRect(x:codeX - codeSize.width, y: (height - codeSize.height) / 2, width: codeSize.width, height: codeSize.height)
            transition.updateFrame(node: codeNode,frame:  codeFrame)
        }
        
        self.bottomSeparatorNode.backgroundColor = presentationData.theme.list.itemBlocksSeparatorColor
        transition.updateFrame(node: self.bottomSeparatorNode, frame: CGRect(origin: CGPoint(x: sideInset, y: height - UIScreenPixel), size: CGSize(width: width - sideInset, height: UIScreenPixel)))
        transition.updateAlpha(node: self.bottomSeparatorNode, alpha: bottomItem == nil ? 0.0 : 1.0)
        
        self.selectionNode.update(size: CGSize(width: width, height: height), theme: presentationData.theme, transition: transition)
        transition.updateFrame(node: self.selectionNode, frame: CGRect(x:0 , y:0 , width:width, height: height))
        return height
    }
}
