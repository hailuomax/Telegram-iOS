//
//  ChatMessageInteractiveTransferNode.swift
//  TelegramUI
//
//  Created by apple on 2019/10/22.
//  Copyright © 2019 Telegram. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Postbox
import SwiftSignalKit
import Display
import TelegramCore
import UniversalMediaPlayer
import TelegramPresentationData
import RxSwift
import AccountContext
import Language
import Extension
import SyncCore

private struct FetchControls {
    let fetch: () -> Void
    let cancel: () -> Void
}

private let titleFont = Font.regular(16.0)
private let descriptionFont = Font.regular(13.0)
private let durationFont = Font.regular(11.0)

final class ChatMessageInteractiveTransferNode: ASDisplayNode {
    private let titleNode: TextNode
    private let descriptionNode: TextNode
    private let descriptionMeasuringNode: TextNode
    private let dateAndStatusNode: ChatMessageDateAndStatusNode
    private let receiveStateNode: TextNode
    public var iconNode: ASImageNode?
    private var tapRecognizer: UITapGestureRecognizer?
    
    var activateLocalContent: () -> Void = { }
    var requestUpdateLayout: (Bool) -> Void = { _ in }
    
    private var context: AccountContext?
    private var message: Message?
    private var themeAndStrings: (ChatPresentationThemeData, PresentationStrings, String)?
    private var file: TelegramMediaTransfer?
    private var progressFrame: CGRect?
    private var streamingCacheStatusFrame: CGRect?
    private var fileIconImage: UIImage?
    private var cloudFetchIconImage: UIImage?
    private var cloudFetchedIconImage: UIImage?
    
    override init() {
        self.titleNode = TextNode()
        self.titleNode.displaysAsynchronously = true
        self.titleNode.isUserInteractionEnabled = false
        
        self.descriptionNode = TextNode()
        self.descriptionNode.displaysAsynchronously = true
        self.descriptionNode.isUserInteractionEnabled = false
        self.dateAndStatusNode = ChatMessageDateAndStatusNode()
        
        self.descriptionMeasuringNode = TextNode()
        self.receiveStateNode = TextNode()
        self.receiveStateNode.displaysAsynchronously = true
        self.receiveStateNode.isUserInteractionEnabled = false
        self.receiveStateNode.isHidden = true
        super.init()
        
        self.addSubnode(self.titleNode)
        self.addSubnode(self.descriptionNode)
        self.addSubnode(self.receiveStateNode)
    }
        
    deinit {
    }
    
    override func didLoad() {
    }
    
    func asyncLayout() -> ( _ item: ChatMessageBubbleContentItem, _ context: AccountContext, _ presentationData: ChatPresentationData, _ message: Message, _ file: TelegramMediaTransfer?, _ incoming: Bool,_ dateAndStatusType: ChatMessageDateAndStatusType?, _ constrainedSize: CGSize) -> (CGFloat, (CGSize) -> (CGFloat, (CGFloat) -> (CGSize, (Bool) -> Void))) {
        
        let titleAsyncLayout = TextNode.asyncLayout(self.titleNode)
        let descriptionAsyncLayout = TextNode.asyncLayout(self.descriptionNode)
        let descriptionMeasuringAsyncLayout = TextNode.asyncLayout(self.descriptionMeasuringNode)
        let statusLayout = self.dateAndStatusNode.asyncLayout()
        let receiveStateAsyncLayout = TextNode.asyncLayout(self.receiveStateNode)
        return {item , context, presentationData, message, file, incoming, dateAndStatusType ,constrainedSize in
            return (CGFloat.greatestFiniteMagnitude, { constrainedSize in
                let titleString = NSAttributedString(string: HLLanguage.Transfer.localized(), font: FontEnum.k_pingFangSC_Regular.toFont(11), textColor: UIColor.hex(.k999999))
                
                var remark = (file?.remark ?? "").replacingOccurrences(of: "\n", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                remark = remark.isEmpty ? HLLanguage.Transfer.messageTip.localized() : remark
                
                var descriptionString: NSAttributedString = NSAttributedString(string: remark, font: titleFont, textColor: UIColor.white)
                if incoming {
                    descriptionString = NSAttributedString(string: remark, font: titleFont, textColor: UIColor.white)
                }
                var receiveState: String = ""
                if let file = file {
                    switch file.receiveStatus {
                    case 1:
                        if incoming {
                            receiveState = HLLanguage.Transaction.Detail.received.localized()
                        } else {
                            receiveState = HLLanguage.BeReceived.localized()
                        }
                    case 2:
                        if incoming {
                            receiveState = HLLanguage.RedemptionExpired.localized()
                        } else {
                            receiveState = HLLanguage.Returned.localized()
                        }
                    case 3:
                        receiveState = HLLanguage.TakeUp.localized()
                    default:
                        break
                    }
                }
                let receiveStateString: NSAttributedString =  NSAttributedString(string: receiveState, font: descriptionFont, textColor: UIColor.white)
                
                let textConstrainedSize = CGSize(width: 155, height: 30)
                
                let (titleLayout, titleApply) = titleAsyncLayout(TextNodeLayoutArguments(attributedString: titleString, backgroundColor: nil, maximumNumberOfLines: 1, truncationType: .middle, constrainedSize: textConstrainedSize, alignment: .natural, cutout: nil, insets: UIEdgeInsets()))
                let (descriptionLayout, descriptionApply) = descriptionAsyncLayout(TextNodeLayoutArguments(attributedString: descriptionString, backgroundColor: nil, maximumNumberOfLines: 1, truncationType: .middle, constrainedSize: textConstrainedSize, alignment: .natural, cutout: nil, insets: UIEdgeInsets()))
                let (descriptionMeasuringLayout, descriptionMeasuringApply) = descriptionMeasuringAsyncLayout(TextNodeLayoutArguments(attributedString: NSAttributedString(string: "", font: descriptionFont, textColor: .black), backgroundColor: nil, maximumNumberOfLines: 1, truncationType: .middle, constrainedSize: textConstrainedSize, alignment: .natural, cutout: nil, insets: UIEdgeInsets()))
                let (receiveStateLayout, receiveStateApply) = receiveStateAsyncLayout(TextNodeLayoutArguments(attributedString: receiveStateString, backgroundColor: nil, maximumNumberOfLines: 1, truncationType: .middle, constrainedSize: textConstrainedSize, alignment: .natural, cutout: nil, insets: UIEdgeInsets()))
                let descriptionMaxWidth : CGFloat = 155.0
                let minLayoutWidth: CGFloat = descriptionMaxWidth + 63.0
                
                var statusSize: CGSize = CGSize(width: 30, height: 14)
                var statusApply: ((Bool) -> Void)?
                
                var consumableContentIcon: UIImage?
                for attribute in message.attributes {
                    if let attribute = attribute as? ConsumableContentMessageAttribute {
                        if !attribute.consumed {
                            if incoming {
                                consumableContentIcon = PresentationResourcesChat.chatBubbleConsumableContentIncomingIcon(presentationData.theme.theme)
                            } else {
                                consumableContentIcon = PresentationResourcesChat.chatBubbleConsumableContentOutgoingIcon(presentationData.theme.theme)
                            }
                        }
                        break
                    }
                }
                
                if let statusType = dateAndStatusType {
                    var edited = false
                    var sentViaBot = false
                    var viewCount: Int?
                    for attribute in message.attributes {
                        if let _ = attribute as? EditedMessageAttribute {
                            edited = true
                        } else if let attribute = attribute as? ViewCountMessageAttribute {
                            viewCount = attribute.count
                        } else if let _ = attribute as? InlineBotMessageAttribute {
                            sentViaBot = true
                        }
                    }
                    if let author = message.author as? TelegramUser, author.botInfo != nil || author.flags.contains(.isSupport) {
                        sentViaBot = true
                    }
                    
                    var dateReactions: [MessageReaction] = []
                    var dateReactionCount = 0
                    if let reactionsAttribute = mergedMessageReactions(attributes: item.message.attributes), !reactionsAttribute.reactions.isEmpty {
                        for reaction in reactionsAttribute.reactions {
                            if reaction.isSelected {
                                dateReactions.insert(reaction, at: 0)
                            } else {
                                dateReactions.append(reaction)
                            }
                            dateReactionCount += Int(reaction.count)
                        }
                    }
                    
                    let dateText = stringForMessageTimestampStatus(accountPeerId: context.account.peerId, message: message, dateTimeFormat: presentationData.dateTimeFormat, nameDisplayOrder: presentationData.nameDisplayOrder, strings: presentationData.strings, reactionCount: dateReactionCount)
                    
                    let (size, apply) = statusLayout(context, presentationData, edited && !sentViaBot, viewCount, dateText, statusType, constrainedSize , dateReactions,.Transfer)
                    statusSize = size
                    statusApply = apply
                }

                return (minLayoutWidth, { boundingWidth in
                    let currentIconFrame = CGRect(origin: CGPoint(x: 10, y: 10), size: CGSize(width: 37.0, height: 37.0))
                    let iconFrame: CGRect? = currentIconFrame
                    let controlAreaWidth: CGFloat = 10 + 37 + 10
                    
                    let titleFrame = CGRect(origin: CGPoint(x: 15, y: 62), size: titleLayout.size)
                    var descriptionFrame: CGRect = CGRect(origin: CGPoint(x: controlAreaWidth, y: 18), size: CGSize(width: 155, height: descriptionLayout.size.height))
                    let fittedLayoutSize: CGSize = CGSize(width: max(minLayoutWidth, descriptionFrame.size.width + 30 + 33), height: 80)
                    var receiveStateFrame: CGRect = CGRect.zero
                    if let file = file,file.receiveStatus > 0 {
                        descriptionFrame = CGRect(origin: CGPoint(x: controlAreaWidth, y: (iconFrame?.origin.y ?? 0)), size: CGSize(width: 155, height: 60))
                        receiveStateFrame = CGRect(origin: CGPoint(x: controlAreaWidth, y: descriptionFrame.origin.y + 25), size: CGSize(width: 155, height: 20))
                        self.receiveStateNode.isHidden = false
                    }
                    return (fittedLayoutSize, { [weak self] synchronousLoads in
                        guard let strongSelf = self else { return }
                        let _ = titleApply()
                        let _ = descriptionApply()
                        let _ = descriptionMeasuringApply()
                        let _ = receiveStateApply()
                        strongSelf.titleNode.frame = titleFrame
                        strongSelf.descriptionNode.frame = descriptionFrame
                        strongSelf.descriptionMeasuringNode.frame = CGRect(origin: CGPoint(), size: descriptionMeasuringLayout.size)
                        strongSelf.receiveStateNode.frame = receiveStateFrame
                        let statusX = boundingWidth - statusSize.width - 10
                        let statusFrame = CGRect(x: statusX, y: 63, width: statusSize.width, height: 14)
                        if let statusApply = statusApply {
                            if strongSelf.dateAndStatusNode.supernode == nil {
                               strongSelf.addSubnode(strongSelf.dateAndStatusNode)
                            }
                            
                            strongSelf.dateAndStatusNode.frame = statusFrame
                            statusApply(false)
                        } else if strongSelf.dateAndStatusNode.supernode != nil {
                            strongSelf.dateAndStatusNode.removeFromSupernode()
                        }
                        
                        if let iconFrame = iconFrame {
                            let iconNode: ASImageNode
                            if let current = strongSelf.iconNode {
                                iconNode = current
                            } else {
                                iconNode = ASImageNode()
                                strongSelf.iconNode = iconNode

                                if ReceiveStatus.init(rawValue: file?.receiveStatus ?? 0) == ReceiveStatus.unReceive {
                                    strongSelf.iconNode?.image = UIImage(bundleImageName: "Chat/Message/ic-transfer")
                                }else {
                                    strongSelf.iconNode?.image = UIImage(bundleImageName: "Chat/Message/TransferSuccess")
                                }
                                 strongSelf.insertSubnode(iconNode, at: 0)
                            }
                            iconNode.frame = iconFrame
                        } else if let iconNode = strongSelf.iconNode {
                            iconNode.removeFromSupernode()
                            strongSelf.iconNode = nil
                        }
                    })
                })
            })
        }
    }
    
    private func updateStatus(animated: Bool) {
        
    }
    
    static func asyncLayout(_ node: ChatMessageInteractiveTransferNode?) -> (_ item: ChatMessageBubbleContentItem, _ context: AccountContext, _ presentationData: ChatPresentationData, _ message: Message,_ file: TelegramMediaTransfer?, _ incoming: Bool,_ dateAndStatusType: ChatMessageDateAndStatusType?, _ constrainedSize: CGSize) -> (CGFloat, (CGSize) -> (CGFloat, (CGFloat) -> (CGSize, (Bool) -> ChatMessageInteractiveTransferNode))) {
        let currentAsyncLayout = node?.asyncLayout()
        return {item, context, presentationData, message, file, incoming, dateAndStatusType ,constrainedSize in
            var transferNode: ChatMessageInteractiveTransferNode
            var fileLayout: (_ item: ChatMessageBubbleContentItem,_ context: AccountContext, _ presentationData: ChatPresentationData, _ message: Message, _ file: TelegramMediaTransfer?, _ incoming: Bool, _ dateAndStatusType: ChatMessageDateAndStatusType?,_ constrainedSize: CGSize) -> (CGFloat, (CGSize) -> (CGFloat, (CGFloat) -> (CGSize, (Bool) -> Void)))
            
            if let node = node, let currentAsyncLayout = currentAsyncLayout {
                transferNode = node
                fileLayout = currentAsyncLayout
            } else {
                transferNode = ChatMessageInteractiveTransferNode()
                fileLayout = transferNode.asyncLayout()
            }
            
            let (initialWidth, continueLayout) = fileLayout(item, context, presentationData, message, file, incoming, dateAndStatusType,constrainedSize)
            
            return (initialWidth, { constrainedSize in
                let (finalWidth, finalLayout) = continueLayout(constrainedSize)
                
                return (finalWidth, { boundingWidth in
                    let (finalSize, apply) = finalLayout(boundingWidth)
                    
                    return (finalSize, { synchronousLoads in
                        apply(synchronousLoads)
                        return transferNode
                    })
                })
            })
        }
    }
    
}

