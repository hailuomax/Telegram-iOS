//
//  ChatMessageRedPacketBubbleContentNode.swift
//  TelegramUI
//
//  Created by apple on 2019/10/11.
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

final class ChatMessageRedPacketBubbleContentNode: ChatMessageBubbleContentNode {
    private var redPacket: TelegramMediaRedPackets?
    private var peerId: PeerId?
    private let interactiveRedPacketNode: ChatMessageInteractiveRedPacketNode
     
    private let contentNode: ChatMessageAttachedContentNode
    private let bgBottomNode : ASDisplayNode = ASDisplayNode()
    private let bgTopNode : ASImageNode = ASImageNode()
    private let bgImageNode : ASDisplayNode = ASDisplayNode()
    override var visibility: ListViewItemNodeVisibility {
        didSet {
            self.contentNode.visibility = self.visibility
        }
    }
    private let viewModel = RedpacketReceiveVM()
    private let disposeBag = DisposeBag()
    
    required init() {
        self.contentNode = ChatMessageAttachedContentNode()
        self.interactiveRedPacketNode = ChatMessageInteractiveRedPacketNode()
        super.init()
        self.bgImageNode.clipsToBounds = true
        self.bgImageNode.cornerRadius = 17
        self.addSubnode(self.bgImageNode)
        self.bgImageNode.addSubnode(self.bgTopNode)
        self.bgImageNode.addSubnode(self.bgBottomNode)
        self.addSubnode(self.interactiveRedPacketNode)
        self.interactiveRedPacketNode.activateLocalContent = { [weak self] in
            if let strongSelf = self {
                if let item = strongSelf.item {
                    let _ = item.controllerInteraction.openMessage(item.message, .default)
                }
            }
        }
        
        self.interactiveRedPacketNode.requestUpdateLayout = { [weak self] _ in
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
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.redPacketTap(_:)))
        self.view.addGestureRecognizer(tapRecognizer)
        

       self.viewModel.redPacketInfo.asObservable().subscribe { [weak self] event in
            guard let self = self else { return }
            guard let model = event.element,let navVC = self.item?.controllerInteraction.navigationController() else{
               return
            }
            guard let currentVC = self.closestViewController as? ChatController else{return}
            var isGroupOrChannel: Bool = false
            let chatLocation = currentVC.chatLocation
            switch chatLocation {
                case let .peer(peerId):
                    isGroupOrChannel = peerId.isGroupOrChannel
                    break
            }
            let peerId = PeerId(namespace: 0, id: Int32(model.senderTelegramId) ?? 0)
            let user = HLAccountManager.shareTgUser.id
            self.viewModel.isSelf = peerId == user
            self.viewModel.received = model.received
            self.viewModel.isGroupOrChannel = model.type != 0
            //已领取过 / 自己的个人红包 / 自己的已过期抢完的群红包
            if model.received || (peerId == user && !isGroupOrChannel) || (peerId == user && isGroupOrChannel && (model.status == 1 || model.status == 2)){
                //跳到领取详情页
                self.gotoRedpacketReceiveVC()
            //未领取抢光/过期 群红包
            }else if (model.status == 1 || model.status == 2) && isGroupOrChannel{
                self.gotoRedPacketErrorAlert(model:model)
            //未领取抢光/过期 个人红包
            }else if model.status == 1 || model.status == 2{
    //            PopViewUtil.dialog(title: model.status == 1 ? HL.TheRedBagHasBeenRobbed.localized() : HL.RedPacketExpired.localized(), containerView: navVC.view)
                //更改为弹窗 但是不显示详情
                self.gotoRedPacketErrorAlert(model:model)
            }else{
                self.gotoGetRedPacketAlert(navVC: navVC, model: model)
            }
            if let item = self.item {
                let context = item.context
                let message = item.message
                print("更新红包信息后，最新的红包状态-->\(model.status)")
                
                let status = ReceiveStatusAdapter.redPacketInfoFit(model)
                
                EncryMessageUtil.updateMessage(context, message, status)
            }
       }.disposed(by: disposeBag)
    }
    
    ///未领取抢光/过期弹窗
    func gotoRedPacketErrorAlert(model: RedPacketInfoModel) {
        guard let currentVC = self.closestViewController as? ChatController else{return}
        RedpacketErrorView.show(vc: currentVC, model: model, context: currentVC.context) {[weak self] in
            self?.gotoRedpacketReceiveVC()
        }
    }
    
    /// 弹出红包领取界面
    func gotoGetRedPacketAlert(navVC: NavigationController,model: RedPacketInfoModel) {
        guard let currentVC = self.closestViewController as? ChatController else{return}
        model.remark = self.redPacket?.remark
        RedpacketAlertView.show(vc: navVC,model: model, context: currentVC.context) { [weak self] in
            self?.viewModel.needReceive = true
            self?.gotoRedpacketReceiveVC()
        }
    }
    
    /// 跳转到红包领取详情页
    func gotoRedpacketReceiveVC() {
        guard let currentVC = self.closestViewController as? ChatController else{return}
        let receiveVC = RedpacketReceiveVC(context: currentVC.context,viewModel: self.viewModel,message:self.item?.message)
        receiveVC.viewModel = self.viewModel
        currentVC.navigationController!.pushViewController(receiveVC, animated: true)
    }
    
    override func asyncLayoutContent() -> (_ item: ChatMessageBubbleContentItem, _ layoutConstants: ChatMessageItemLayoutConstants, _ preparePosition: ChatMessageBubblePreparePosition, _ messageSelection: Bool?, _ constrainedSize: CGSize) -> (ChatMessageBubbleContentProperties, CGSize?, CGFloat, (CGSize, ChatMessageBubbleContentPosition) -> (CGFloat, (CGFloat) -> (CGSize, (ListViewItemUpdateAnimation, Bool) -> Void))) {
        
        let interactiveRedPacketLayout = self.interactiveRedPacketNode.asyncLayout()
        
        return { item, layoutConstants, preparePosition, _, constrainedSize in
            var selectedFile: TelegramMediaRedPackets?
            for media in item.message.media {
                if let telegramFile = media as? TelegramMediaRedPackets {
                    selectedFile = telegramFile
                }
            }
            
            self.redPacket = selectedFile
            
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
            
            let (initialWidth, refineLayout) = interactiveRedPacketLayout(item, item.context, item.presentationData, item.message, selectedFile, item.message.effectivelyIncoming(item.context.account.peerId), statusType, CGSize(width: constrainedSize.width - layoutConstants.redpacket.bubbleInsets.left - layoutConstants.redpacket.bubbleInsets.right, height: constrainedSize.height))
            
            let contentProperties = ChatMessageBubbleContentProperties(hidesSimpleAuthorHeader: false, headerSpacing: 10.0, hidesBackground: .always, forceFullCorners: true, forceAlignment: .none)
            
            return (contentProperties, nil, initialWidth + layoutConstants.redpacket.bubbleInsets.left + layoutConstants.redpacket.bubbleInsets.right, { constrainedSize, position in
                let (refinedWidth, finishLayout) = refineLayout(CGSize(width: constrainedSize.width - layoutConstants.redpacket.bubbleInsets.left - layoutConstants.redpacket.bubbleInsets.right, height: constrainedSize.height))
                
                return (refinedWidth + layoutConstants.redpacket.bubbleInsets.left + layoutConstants.redpacket.bubbleInsets.right, { boundingWidth in
                    let (fileSize, fileApply) = finishLayout(boundingWidth - layoutConstants.redpacket.bubbleInsets.left - layoutConstants.redpacket.bubbleInsets.right)
                    
                    return (CGSize(width: fileSize.width + layoutConstants.redpacket.bubbleInsets.left + layoutConstants.redpacket.bubbleInsets.right, height: fileSize.height + layoutConstants.redpacket.bubbleInsets.top + layoutConstants.redpacket.bubbleInsets.bottom), { [weak self] _, synchronousLoads in
                        if let strongSelf = self {
                            strongSelf.item = item
                            strongSelf.interactiveRedPacketNode.frame = CGRect(origin: CGPoint(x: layoutConstants.redpacket.bubbleInsets.left, y: layoutConstants.redpacket.bubbleInsets.top), size: fileSize)
                            let bgImageRect = CGRect.init(x: 0, y: 0, width: fileSize.width, height: 60)
                            let bgBottomRect = CGRect.init(x: 0, y: 60, width: fileSize.width, height: 20)
                            let bgContentRect = CGRect.init(x: 0, y: 0, width: fileSize.width, height: 80)
                            strongSelf.bgImageNode.frame = bgContentRect
                            strongSelf.bgBottomNode.frame = bgBottomRect
                            strongSelf.bgTopNode.frame = bgImageRect
                            if ReceiveStatus(rawValue: strongSelf.redPacket?.receiveStatus ?? 0) == ReceiveStatus.unReceive {
                                strongSelf.bgTopNode.image = UIImage.setGradientImageWithBounds(rect: bgImageRect, colors: [ColorEnum.kFF9A4E.toColor(),ColorEnum.kFF4545.toColor()], type: 1)
                                strongSelf.interactiveRedPacketNode.iconNode?.image = UIImage(bundleImageName: "Chat/RedPacketIcon")
                            } else {
                                strongSelf.bgTopNode.image = UIImage.colorImg(ColorEnum.kFFB292.toColor())
                                strongSelf.interactiveRedPacketNode.iconNode?.image = UIImage(bundleImageName: "Chat/RedPacketReceiveIcon")
                            }
                            
                            strongSelf.bgBottomNode.backgroundColor = ColorEnum.kFFEBDB.toColor()
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
            /*if let webPage = self.webPage, case let .Loaded(content) = webPage.content {
                if content.instantPage != nil {
                    return .instantPage
                }
            }*/
        }
        return .none
    }
    
    override func updateHiddenMedia(_ media: [Media]?) -> Bool {
        return self.contentNode.updateHiddenMedia(media)
    }
    
    override func transitionNode(messageId: MessageId, media: Media) -> (ASDisplayNode, CGRect ,() -> (UIView?, UIView?))? {
        if self.item?.message.id != messageId {
            return nil
        }
        return self.contentNode.transitionNode(media: media)
    }
    
    @objc func redPacketTap(_ recognizer: UITapGestureRecognizer) {
        
        guard let redPacketId = self.redPacket?.redPacketId,
            !redPacketId.isEmpty else {
                HUD.flash(.label("请更新到最新版本领取红包"), onView: nil, delay: 1)
                return
        }
        
        guard case .ended = recognizer.state,
            let currentVC = self.closestViewController as? ChatController else{return}
        currentVC.view.endEditing(true)
        let block = { [weak self] in
            guard let self = self else {return}
            self.viewModel.redPacketId  = redPacketId
            self.viewModel.receiverName = HLAccountManager.shareTgUser.nameOrPhone
            self.viewModel.getRedPacketInfo()
            .netWorkState {(state) in
              switch state {
                case .loading:
                    HUD.allowsInteraction = false
                    HUD.dimsBackground = true
                    HUD.show(.systemActivity,onView: currentVC.view)
                case .success:
                    HUD.hide()
                case let .error(error):
                    HUD.flash(.label(error.msg),delay: 1.0)
              }
            }.load(self.disposeBag)
        }
        
        guard HLAccountManager.shareAccount.token == nil || HLAccountManager.shareAccount.token!.isEmpty else {
            block()
            return
        }
        
        assetVerification(currentVC: currentVC)
        
    }
}

