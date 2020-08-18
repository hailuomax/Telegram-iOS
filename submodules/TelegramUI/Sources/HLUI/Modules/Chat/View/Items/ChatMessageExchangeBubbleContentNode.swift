//
//  ChatMessageRedPacketBubbleContentNode.swift
//  TelegramUI
//
//  Created by hailuo on 2019/10/11.
//  Copyright © 2019 Telegram. All rights reserved.
//

import UIKit
import Postbox
import Display
import AsyncDisplayKit
import SwiftSignalKit
import TelegramCore
import Display
import RxSwift
import Extension
import UI
import ViewModel
import HL
import Language
import Account
import AccountContext
import Model

final class ChatMessageExchangeBubbleContentNode: ChatMessageBubbleContentNode {
    private var exchange: TelegramMediaExchange?
    private var peerId: PeerId?
    private let interactiveExchangeNode: ChatMessageInteractiveExchangeNode
     
    private let contentNode: ChatMessageAttachedContentNode
    private let bgBottomNode : ASDisplayNode = ASDisplayNode()
    private let bgTopNode : ASImageNode = ASImageNode()
    private let bgImageNode : ASDisplayNode = ASDisplayNode()
    
    override var visibility: ListViewItemNodeVisibility {
        didSet {
            self.contentNode.visibility = self.visibility
        }
    }
    
    private let disposeBag = DisposeBag()
    
    required init() {
        self.contentNode = ChatMessageAttachedContentNode()
        self.interactiveExchangeNode = ChatMessageInteractiveExchangeNode()
        super.init()
        self.bgImageNode.clipsToBounds = true
        self.bgImageNode.cornerRadius = 17
        self.addSubnode(self.bgImageNode)
        self.bgImageNode.addSubnode(self.bgTopNode)
        self.bgImageNode.addSubnode(self.bgBottomNode)
        self.addSubnode(self.interactiveExchangeNode)
        self.interactiveExchangeNode.activateLocalContent = { [weak self] in
            if let strongSelf = self {
                if let item = strongSelf.item {
                    let _ = item.controllerInteraction.openMessage(item.message, .default)
                }
            }
        }
        
        self.interactiveExchangeNode.requestUpdateLayout = { [weak self] _ in
            if let strongSelf = self {
                if let item = strongSelf.item {
                    let _ = item.controllerInteraction.requestMessageUpdate(item.message.id)
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didLoad() {
        super.didLoad()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.exchangeTap(_:)))
        self.view.addGestureRecognizer(tapRecognizer)

    }
    
    override func asyncLayoutContent() -> (_ item: ChatMessageBubbleContentItem, _ layoutConstants: ChatMessageItemLayoutConstants, _ preparePosition: ChatMessageBubblePreparePosition, _ messageSelection: Bool?, _ constrainedSize: CGSize) -> (ChatMessageBubbleContentProperties, CGSize?, CGFloat, (CGSize, ChatMessageBubbleContentPosition) -> (CGFloat, (CGFloat) -> (CGSize, (ListViewItemUpdateAnimation, Bool) -> Void))) {
        
        let interactiveExchangeLayout = self.interactiveExchangeNode.asyncLayout()
        
        return { item, layoutConstants, preparePosition, _, constrainedSize in
            var selectedFile: TelegramMediaExchange?
            for media in item.message.media {
                if let telegramFile = media as? TelegramMediaExchange {
                    selectedFile = telegramFile
                }
            }
            
            self.exchange = selectedFile
            
            let incoming = item.message.effectivelyIncoming(item.context.account.peerId)
            let statusType: ChatMessageDateAndStatusType?
            switch preparePosition {
                case .linear(_, .None):
                    if incoming {
                        statusType = .BubbleIncoming
                    } else {
                        if item.message.flags.contains(.Failed) {
                            statusType = .BubbleOutgoing(.Failed)
                        } else if item.message.flags.isSending && !item.message.isSentOrAcknowledged {
                            statusType = .BubbleOutgoing(.Sending)
                        } else {
                            statusType = .BubbleOutgoing(.Sent(read: item.read))
                        }
                    }
                default:
                    statusType = nil
            }
            
            let (initialWidth, refineLayout) = interactiveExchangeLayout(item ,item.context, item.presentationData, item.message, selectedFile, item.message.effectivelyIncoming(item.context.account.peerId), statusType, CGSize(width: constrainedSize.width - layoutConstants.redpacket.bubbleInsets.left - layoutConstants.redpacket.bubbleInsets.right, height: constrainedSize.height))
            
            let contentProperties = ChatMessageBubbleContentProperties(hidesSimpleAuthorHeader: false, headerSpacing: 10.0, hidesBackground: .always, forceFullCorners: true, forceAlignment: .none)
            
            return (contentProperties, nil, initialWidth + layoutConstants.redpacket.bubbleInsets.left + layoutConstants.redpacket.bubbleInsets.right, { constrainedSize, position in
                let (refinedWidth, finishLayout) = refineLayout(CGSize(width: constrainedSize.width - layoutConstants.redpacket.bubbleInsets.left - layoutConstants.redpacket.bubbleInsets.right, height: constrainedSize.height))
                
                return (refinedWidth + layoutConstants.redpacket.bubbleInsets.left + layoutConstants.redpacket.bubbleInsets.right, { boundingWidth in
                    let (fileSize, fileApply) = finishLayout(boundingWidth - layoutConstants.redpacket.bubbleInsets.left - layoutConstants.redpacket.bubbleInsets.right)
                    
                    return (CGSize(width: fileSize.width + layoutConstants.redpacket.bubbleInsets.left + layoutConstants.redpacket.bubbleInsets.right, height: fileSize.height + layoutConstants.redpacket.bubbleInsets.top + layoutConstants.redpacket.bubbleInsets.bottom), { [weak self] _, synchronousLoads in
                        if let strongSelf = self {
                            strongSelf.item = item
                            strongSelf.interactiveExchangeNode.frame = CGRect(origin: CGPoint(x: layoutConstants.redpacket.bubbleInsets.left, y: layoutConstants.redpacket.bubbleInsets.top), size: fileSize)
                            let bgImageRect = CGRect.init(x: 0, y: 0, width: fileSize.width, height: 60)
                            let bgBottomRect = CGRect.init(x: 0, y: 60, width: fileSize.width, height: 20)
                            let bgContentRect = CGRect.init(x: 0, y: 0, width: fileSize.width, height: 80)
                            strongSelf.bgImageNode.frame = bgContentRect
                            strongSelf.bgBottomNode.frame = bgBottomRect
                            strongSelf.bgTopNode.frame = bgImageRect
                            strongSelf.bgTopNode.image = UIImage.setGradientImageWithBounds(rect: bgImageRect, colors: [ColorEnum.k68B4FF.toColor(),ColorEnum.k429BFF.toColor()], type: 1)
                            strongSelf.bgBottomNode.backgroundColor = UIColor.white
                            strongSelf.supernode?.clipsToBounds = true
                            fileApply(synchronousLoads)
                        }
                    })
                })
            })
        }
    }
    
    override func animateInsertion(_ currentTimestamp: Double, duration: Double) {
        self.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.25)
    }
    
    override func animateAdded(_ currentTimestamp: Double, duration: Double) {
        self.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.25)
    }
    
    override func animateRemoved(_ currentTimestamp: Double, duration: Double) {
        self.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.25, removeOnCompletion: false)
    }
    
    override func animateInsertionIntoBubble(_ duration: Double) {
        self.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.25)
    }
    
    func tapActionAtPoint(_ point: CGPoint, gesture: TapLongTapOrDoubleTapGesture) -> ChatMessageBubbleContentTapAction {
        return .none
    }
    
    override func updateHiddenMedia(_ media: [Media]?) -> Bool {
        return self.contentNode.updateHiddenMedia(media)
    }
    
    override func transitionNode(messageId: MessageId, media: Media) -> (ASDisplayNode, CGRect,() -> (UIView?, UIView?))? {
        if self.item?.message.id != messageId {
            return nil
        }
        return self.contentNode.transitionNode(media: media)
    }
    
    @objc func exchangeTap(_ recognizer: UITapGestureRecognizer) {
        
        guard let exchangeId = self.exchange?.exchangeId,
            !exchangeId.isEmpty else {
                HUD.flash(.label("请更新到最新版本进行闪兑"), onView: nil, delay: 1)
                return
        }
        
        guard case .ended = recognizer.state,
            let currentVC = self.closestViewController as? ChatController else{
            return
        }
        
        let block = { [weak self] in
            guard let self = self else {return}
            
            let exchangeVM = ExchangeVM()
            exchangeVM.exchangeId = exchangeId
            let exchangeVC = ExchangeOrderCreateVC(context: currentVC.context)
            exchangeVC.isEnterFromGroup = true
            exchangeVC.viewModel = exchangeVM
            currentVC.navigationController?.pushViewController(exchangeVC, animated: true)
        }
        guard !HLAccountManager.walletIsLogined else {
            block()
            return
        }
        
        assetVerification(currentVC: currentVC)
        
    }
}



