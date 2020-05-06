//
//  ChatMessageTransferBubbleContentNode.swift
//  TelegramUI
//
//  Created by apple on 2019/10/22.
//  Copyright © 2019 Telegram. All rights reserved.
//

import Foundation
import UIKit
import Postbox
import Display
import AsyncDisplayKit
import SwiftSignalKit
import TelegramCore
import ViewModel
import RxSwift
import AccountContext
import Account
import Model
import Repo
import HL
import UI
import ViewModel

final class ChatMessageTransferBubbleContentNode: ChatMessageBubbleContentNode {
    private var transfer: TelegramMediaTransfer?
    private var peerId: PeerId?
    private let interactiveTransferNode: ChatMessageInteractiveTransferNode
    private let bgBottomNode : ASDisplayNode = ASDisplayNode()
    private let bgTopNode : ASImageNode = ASImageNode()
    private let bgImageNode : ASDisplayNode = ASDisplayNode()
    private let contentNode: ChatMessageAttachedContentNode
    
    override var visibility: ListViewItemNodeVisibility {
        didSet {
            self.contentNode.visibility = self.visibility
        }
    }
    
    required init() {
        self.contentNode = ChatMessageAttachedContentNode()
        self.interactiveTransferNode = ChatMessageInteractiveTransferNode()
        super.init()
        self.bgImageNode.clipsToBounds = true
        self.bgImageNode.cornerRadius = 17
        self.addSubnode(self.bgImageNode)
        self.bgImageNode.addSubnode(self.bgTopNode)
        self.bgImageNode.addSubnode(self.bgBottomNode)
        self.addSubnode(self.interactiveTransferNode)
        self.interactiveTransferNode.activateLocalContent = { [weak self] in
            if let strongSelf = self {
                if let item = strongSelf.item {
                    let _ = item.controllerInteraction.openMessage(item.message, .default)
                }
            }
        }
        
        self.interactiveTransferNode.requestUpdateLayout = { [weak self] _ in
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
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.transferTap(_:)))
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func asyncLayoutContent() -> (_ item: ChatMessageBubbleContentItem, _ layoutConstants: ChatMessageItemLayoutConstants, _ preparePosition: ChatMessageBubblePreparePosition, _ messageSelection: Bool?, _ constrainedSize: CGSize) -> (ChatMessageBubbleContentProperties, CGSize?, CGFloat, (CGSize, ChatMessageBubbleContentPosition) -> (CGFloat, (CGFloat) -> (CGSize, (ListViewItemUpdateAnimation, Bool) -> Void))) {
        
        let interactiveRedPacketLayout = self.interactiveTransferNode.asyncLayout()
        
        return { item, layoutConstants, preparePosition, _, constrainedSize in
            var selectedFile: TelegramMediaTransfer?
            for media in item.message.media {
                if let telegramFile = media as? TelegramMediaTransfer {
                    selectedFile = telegramFile
                }
            }
            
            self.transfer = selectedFile
            
            let incoming = item.message.effectivelyIncoming(item.context.account.peerId)
            var statusType: ChatMessageDateAndStatusType?
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
            
            let (initialWidth, refineLayout) = interactiveRedPacketLayout(item, item.context, item.presentationData, item.message, selectedFile, item.message.effectivelyIncoming(item.context.account.peerId), statusType, CGSize(width: constrainedSize.width - layoutConstants.redpacket.bubbleInsets.left - layoutConstants.redpacket.bubbleInsets.right, height: constrainedSize.height))
            
            let contentProperties = ChatMessageBubbleContentProperties(hidesSimpleAuthorHeader: false, headerSpacing: 10.0, hidesBackground: .always, forceFullCorners: true, forceAlignment: .none)
            
            return (contentProperties, nil, initialWidth + layoutConstants.redpacket.bubbleInsets.left + layoutConstants.redpacket.bubbleInsets.right, { constrainedSize, position in
                let (refinedWidth, finishLayout) = refineLayout(CGSize(width: constrainedSize.width - layoutConstants.redpacket.bubbleInsets.left - layoutConstants.redpacket.bubbleInsets.right, height: constrainedSize.height))
                
                return (refinedWidth + layoutConstants.redpacket.bubbleInsets.left + layoutConstants.redpacket.bubbleInsets.right, { boundingWidth in
                    let (fileSize, fileApply) = finishLayout(boundingWidth - layoutConstants.redpacket.bubbleInsets.left - layoutConstants.redpacket.bubbleInsets.right)
                    
                    return (CGSize(width: fileSize.width + layoutConstants.redpacket.bubbleInsets.left + layoutConstants.redpacket.bubbleInsets.right, height: fileSize.height + layoutConstants.redpacket.bubbleInsets.top + layoutConstants.redpacket.bubbleInsets.bottom), { [weak self] _, synchronousLoads in
                        if let strongSelf = self {
                            strongSelf.item = item
                            strongSelf.interactiveTransferNode.frame = CGRect(origin: CGPoint(x: layoutConstants.redpacket.bubbleInsets.left, y: layoutConstants.redpacket.bubbleInsets.top), size: fileSize)
                            let bgImageRect = CGRect.init(x: 0, y: 0, width: fileSize.width, height: 60)
                            let bgBottomRect = CGRect.init(x: 0, y: 60, width: fileSize.width, height: 20)
                            let bgContentRect = CGRect.init(x: 0, y: 0, width: fileSize.width, height: 80)
                            strongSelf.bgImageNode.frame = bgContentRect
                            strongSelf.bgBottomNode.frame = bgBottomRect
                            strongSelf.bgTopNode.frame = bgImageRect
                            if ReceiveStatus.init(rawValue: strongSelf.transfer?.receiveStatus ?? 0) == ReceiveStatus.unReceive {
                                strongSelf.bgTopNode.image = UIImage.setGradientImageWithBounds(rect: bgImageRect, colors: [ColorEnum.kFFB400.toColor(),ColorEnum.kFF933E.toColor()], type: 1)
                            } else {
                                strongSelf.bgTopNode.image =
                                   UIImage.colorImg(ColorEnum.kFFE2C2.toColor())
                            }
                            
                            strongSelf.bgBottomNode.backgroundColor = .white
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
        if self.bounds.contains(point) {
        }
        return .none
    }
    
    override func updateHiddenMedia(_ media: [Media]?) -> Bool {
        return self.contentNode.updateHiddenMedia(media)
    }
    
    override func transitionNode(messageId: MessageId, media: Media) -> (ASDisplayNode,CGRect ,() -> (UIView?, UIView?))? {
        if self.item?.message.id != messageId {
            return nil
        }
        return self.contentNode.transitionNode(media: media)
    }
    
    @objc func transferTap(_ recognizer: UITapGestureRecognizer) {
        
        guard let transferId = self.transfer?.transferId,
            !transferId.isEmpty else {
                HUD.flash(.label("请更新到最新版本接收转账"), onView: nil, delay: 1)
                return
        }
        
        guard case .ended = recognizer.state,
            let currentVC = self.closestViewController as? ChatController else{
            return
        }
        currentVC.view.endEditing(true)
        let block = { [weak self] in
            guard let self = self,
                let navVC = self.item?.controllerInteraction.navigationController() else{ return }
            let receiveVC = TransferGetVC(context: self.item!.context, transferId: transferId,message: self.item?.message)
            navVC.pushViewController(receiveVC)
        }
        guard HLAccountManager.shareAccount.token == nil || HLAccountManager.shareAccount.token!.isEmpty else {
            block()
            return
        }
        
        assetVerification(currentVC: currentVC)
    }
}


