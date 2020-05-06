//
//  ChatMessageInteractiveRedPacketNode.swift
//  TelegramUI#shared
//
//  Created by lemon on 2020/4/29.
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
import Language
import AccountContext
import Extension
import SyncCore

private struct FetchControls {
    let fetch: () -> Void
    let cancel: () -> Void
}

private let titleFont = Font.regular(16.0)
private let descriptionFont = Font.regular(13.0)
private let durationFont = Font.regular(11.0)

final class ChatMessageInteractiveRedPacketNode: ASDisplayNode {
    private let descriptionNode: TextNode
    private let receiveStateNode: TextNode
    private let dateAndStatusNode: ChatMessageDateAndStatusNode
    
    private var iconNode: ASImageNode?
    private var tapRecognizer: UITapGestureRecognizer?
    ///左下角红包
    private let nameNode: TextNode

    var activateLocalContent: () -> Void = { }
    var requestUpdateLayout: (Bool) -> Void = { _ in }
    
    private var context: AccountContext?
    private var message: Message?
    private var themeAndStrings: (ChatPresentationThemeData, PresentationStrings, String)?
    private var file: TelegramMediaRedPackets?
    private var progressFrame: CGRect?
    private var streamingCacheStatusFrame: CGRect?
    private var fileIconImage: UIImage?
    private var cloudFetchIconImage: UIImage?
    private var cloudFetchedIconImage: UIImage?
    
    override init() {
        self.descriptionNode = TextNode()
        self.receiveStateNode = TextNode()
        self.nameNode = TextNode()
        self.descriptionNode.displaysAsynchronously = true
        self.descriptionNode.isUserInteractionEnabled = false
        self.receiveStateNode.displaysAsynchronously = true
        self.receiveStateNode.isUserInteractionEnabled = false
        self.receiveStateNode.isHidden = true
        self.dateAndStatusNode = ChatMessageDateAndStatusNode()
//        self.descriptionMeasuringNode = TextNode()
        super.init()
        self.addSubnode(self.descriptionNode)
        self.addSubnode(self.receiveStateNode)
        self.addSubnode(self.nameNode)
    }
        
    deinit {
    }
    
    override func didLoad() {
    }
        
    func asyncLayout() -> (_ item: ChatMessageBubbleContentItem ,_ context: AccountContext, _ presentationData: ChatPresentationData, _ message: Message, _ file: TelegramMediaRedPackets?, _ incoming: Bool,_ dateAndStatusType: ChatMessageDateAndStatusType?, _ constrainedSize: CGSize) -> (CGFloat, (CGSize) -> (CGFloat, (CGFloat) -> (CGSize, (Bool) -> Void))) {
        
        
        let descriptionAsyncLayout = TextNode.asyncLayout(self.descriptionNode)
//        let descriptionMeasuringAsyncLayout = TextNode.asyncLayout(self.descriptionMeasuringNode)
        let receiveStateAsyncLayout = TextNode.asyncLayout(self.receiveStateNode)
        let statusLayout = self.dateAndStatusNode.asyncLayout()
        
        return {item, context, presentationData, message, file, incoming, dateAndStatusType ,constrainedSize in
            return (CGFloat.greatestFiniteMagnitude, { constrainedSize in
                
                var remark = (file?.remark ?? "").replacingOccurrences(of: "\n", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                remark = remark.isEmpty ? HLLanguage.Congratulations.localized() : remark

                
                let descriptionString: NSAttributedString =  NSAttributedString(string: remark, font: titleFont, textColor: UIColor.white)
                let textConstrainedSize = CGSize(width: 155, height: 30)
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
                
                let (descriptionLayout, descriptionApply) = descriptionAsyncLayout(TextNodeLayoutArguments(attributedString: descriptionString, backgroundColor: nil, maximumNumberOfLines: 1, truncationType: .middle, constrainedSize: textConstrainedSize, alignment: .natural, cutout: nil, insets: UIEdgeInsets()))

                let (receiveStateLayout, receiveStateApply) = receiveStateAsyncLayout(TextNodeLayoutArguments(attributedString: receiveStateString, backgroundColor: nil, maximumNumberOfLines: 1, truncationType: .middle, constrainedSize: textConstrainedSize, alignment: .natural, cutout: nil, insets: UIEdgeInsets()))
                let descriptionMaxWidth : CGFloat = 155.0
                let minLayoutWidth: CGFloat = descriptionMaxWidth + 63.0
                
                
                var statusSize: CGSize = CGSize(width: 30, height: 20)
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
                    
                    let (size, apply) = statusLayout( context,presentationData, edited && !sentViaBot, viewCount, dateText, statusType, constrainedSize,dateReactions,.Redpacket)
                    statusSize = size
                    statusApply = apply
                }
                
                let nameAsyncLayout = TextNode.asyncLayout(self.nameNode)
                
                let nameStr = NSAttributedString(string: HLLanguage.RedPacket.localized(), font: FontEnum.k_pingFangSC_Regular.toFont(11), textColor: UIColor.hex(.kFF9A58))
                
                let (nameLayout, nameApply) = nameAsyncLayout(TextNodeLayoutArguments(attributedString: nameStr, maximumNumberOfLines: 1, truncationType: .middle, constrainedSize: CGSize(width: 150, height: 12)))
                
                return (minLayoutWidth, { boundingWidth in
                    let currentIconFrame = CGRect(origin: CGPoint(x: 10, y: 10.0), size: CGSize(width: 33.0, height: 40.0))
                    let iconFrame: CGRect? = currentIconFrame
                    let controlAreaWidth: CGFloat = 10 + 6 + 33 + 10
                    var descriptionFrame: CGRect = CGRect(origin: CGPoint(x: controlAreaWidth, y: (iconFrame?.origin.y ?? 0) + 12), size: CGSize(width: 155, height: 60))
                    var receiveStateFrame: CGRect = CGRect.zero
                    if let file = file,file.receiveStatus > 0 {
                        descriptionFrame = CGRect(origin: CGPoint(x: controlAreaWidth, y: (iconFrame?.origin.y ?? 0)), size: CGSize(width: 155, height: 60))
                        receiveStateFrame = CGRect(origin: CGPoint(x: controlAreaWidth, y: descriptionFrame.origin.y + 25), size: CGSize(width: 155, height: 20))
                        self.receiveStateNode.isHidden = false
                    }
                    let fittedLayoutSize: CGSize = CGSize(width: max(minLayoutWidth, descriptionFrame.size.width + 30 + 33), height: 80)
                    let nameFrame: CGRect = CGRect(origin: CGPoint(x: 15, y: 62), size: nameLayout.size)
                    return (fittedLayoutSize, { [weak self] synchronousLoads in
                        guard let strongSelf = self else { return }
                        let _ = descriptionApply()
                        let _ = receiveStateApply()
                        let _ = nameApply()
                        
                        let statusFrame = CGRect(x: boundingWidth - statusSize.width - 10, y: 63, width: statusSize.width, height: 20)
                        if let statusApply = statusApply {
                            if strongSelf.dateAndStatusNode.supernode == nil {
                               strongSelf.addSubnode(strongSelf.dateAndStatusNode)
                            }
                            
                            strongSelf.dateAndStatusNode.frame = statusFrame
                            statusApply(false)
                        } else if strongSelf.dateAndStatusNode.supernode != nil {
                            strongSelf.dateAndStatusNode.removeFromSupernode()
                        }
                    print("descriptionNode.frame->\(strongSelf.descriptionNode.frame)")
                        strongSelf.descriptionNode.frame = descriptionFrame
                        strongSelf.receiveStateNode.frame = receiveStateFrame
                        strongSelf.nameNode.frame = nameFrame
                        
                        if let iconFrame = iconFrame {
                            let iconNode: ASImageNode
                            if let current = strongSelf.iconNode {
                                iconNode = current
                            } else {
                                iconNode = ASImageNode()
                                strongSelf.iconNode = iconNode
                                strongSelf.iconNode?.image = UIImage(bundleImageName: "Chat/RedPacketIcon")
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
}
