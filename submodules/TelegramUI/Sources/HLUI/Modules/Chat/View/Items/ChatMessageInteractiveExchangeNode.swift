//
//  ChatMessageInteractiveExchangeNode.swift
//  TelegramUI#shared
//
//  Created by lemon on 2020/5/6.
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
import Then
import AccountContext
import Language
import Extension
import Account
import SyncCore

private struct FetchControls {
    let fetch: () -> Void
    let cancel: () -> Void
}


final class ChatMessageInteractiveExchangeNode: ASDisplayNode {
    
    private let descriptionNode: TextNode
    
    private let dateAndStatusNode: ChatMessageDateAndStatusNode
    ///显示汇率，无汇率时，显示“闪兑”
    private let rateStrNode: TextNode
    
    private var iconNode: ASImageNode?
    private var tapRecognizer: UITapGestureRecognizer?
    
    var activateLocalContent: () -> Void = { }
    var requestUpdateLayout: (Bool) -> Void = { _ in }
    
    private var context: AccountContext?
    private var message: Message?
    private var themeAndStrings: (ChatPresentationThemeData, PresentationStrings, String)?
    private var file: TelegramMediaExchange?
    private var progressFrame: CGRect?
    private var streamingCacheStatusFrame: CGRect?
    private var fileIconImage: UIImage?
    private var cloudFetchIconImage: UIImage?
    private var cloudFetchedIconImage: UIImage?
    
    override init() {
       
        self.dateAndStatusNode = ChatMessageDateAndStatusNode()
        self.descriptionNode = TextNode().then{
            $0.displaysAsynchronously = true
            $0.isUserInteractionEnabled = false
            $0.clipsToBounds = false
        }
        
        self.rateStrNode = TextNode().then{
            $0.displaysAsynchronously = true
            $0.isUserInteractionEnabled = false
            $0.clipsToBounds = false
        }
        
        
        super.init()
        
        self.addSubnode(self.descriptionNode)
        self.addSubnode(self.rateStrNode)
    }
        
    deinit {
    }
    
    override func didLoad() {
    }
    
    func asyncLayout() -> (_ item: ChatMessageBubbleContentItem ,_ context: AccountContext, _ presentationData: ChatPresentationData, _ message: Message, _ file: TelegramMediaExchange?, _ incoming: Bool,_ dateAndStatusType: ChatMessageDateAndStatusType?, _ constrainedSize: CGSize) -> (CGFloat, (CGSize) -> (CGFloat, (CGFloat) -> (CGSize, (Bool) -> Void))) {
        
        
        let descriptionAsyncLayout = TextNode.asyncLayout(self.descriptionNode)
        let rateAsyncLayout = TextNode.asyncLayout(self.rateStrNode)
        
        let statusLayout = self.dateAndStatusNode.asyncLayout()
        return {item, context, presentationData, message, file, incoming, dateAndStatusType ,constrainedSize in
            return (CGFloat.greatestFiniteMagnitude, { constrainedSize in
                
                ///闪兑气泡的总宽度
                let minLayoutWidth: CGFloat = 218
                
                print("---->\(constrainedSize)")
                print("file---->\(String(describing: file?.exchangeId)) ")
                let myId = HLAccountManager.shareTgUser.id.id
                print("---->\(myId)")
                print("---->\(String(describing: file?.senderId))")
                let isSender = myId == Int32(file?.senderId ?? "0")
                let iconName = "ic-exchange"
                
                //如果获取不到闪兑id，证明需要用户更新版本才能进行闪兑
                var desc = ""
                if !file!.exchangeId.isEmpty{
                    desc     = isSender ? "\(file?.outCoin ?? "")\n\(HLLanguage.Exchange.localized())\(file?.inCoin ?? "")" : "\(file?.inCoin ?? "")\n\(HLLanguage.Exchange.localized())\(file?.outCoin ?? "")"
                }
                
                //汇率不显示，注释代码
//                let rateStr: String = file?.rateStr ?? HL.Exchange.localized()
                let rateStr = HLLanguage.FastExchange.localized()
                
                let descriptionString: NSAttributedString =  NSAttributedString(string: desc, font: FontEnum.k_pingFangSC_Regular.toFont(14), textColor: UIColor.white)
                let rateString: NSAttributedString = NSAttributedString(string: rateStr, font: FontEnum.k_pingFangSC_Regular.toFont(11), textColor: UIColor.hex(.k999999))
                
                let textWidth = minLayoutWidth - 78
                let textConstrainedSize = CGSize(width: textWidth, height: constrainedSize.height)
        
                let (descriptionLayout, descriptionApply) = descriptionAsyncLayout(TextNodeLayoutArguments(attributedString: descriptionString, backgroundColor: nil, maximumNumberOfLines: 2, truncationType: .middle, constrainedSize: textConstrainedSize, alignment: .natural, cutout: nil, insets: UIEdgeInsets()))
                let (rateLayout, rateApply) = rateAsyncLayout(TextNodeLayoutArguments(attributedString: rateString, maximumNumberOfLines: 1, truncationType: .middle, constrainedSize: CGSize(width: 150, height: 12)))
                
                
                
                var statusSize: CGSize = CGSize(width: 30, height: 14)
                var statusApply: ((Bool) -> Void)?
                
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
                    
                    let (size, apply) = statusLayout(context ,presentationData, edited && !sentViaBot, viewCount, dateText, statusType, constrainedSize,dateReactions,.Exchange)
                    statusSize = size
                    statusApply = apply
                }
                
                return (minLayoutWidth, { boundingWidth in
                    
                    let currentIconFrame = CGRect(origin: CGPoint(x: 15, y: 10), size: CGSize(width: 37.0, height: 37.0))
                    let iconFrame: CGRect? = currentIconFrame
                    
                    let descriptionFrame: CGRect = CGRect(origin: CGPoint(x: 62, y: 10), size: CGSize(width: textWidth, height: descriptionLayout.size.height))
                    let rateFrame: CGRect = CGRect(origin: CGPoint(x: 15, y: 62), size: rateLayout.size)
                    
                    let fittedLayoutSize: CGSize = CGSize(width: max(minLayoutWidth, descriptionFrame.size.width + 30 + 33), height: 80)
                    return (fittedLayoutSize, { [weak self] synchronousLoads in
                        guard let self = self else { return }
                        
                        _ = descriptionApply()
                        _ = rateApply()
                        
                        self.descriptionNode.frame = descriptionFrame
                        self.rateStrNode.frame = rateFrame
                        
                        let statusX = boundingWidth - statusSize.width - 10
                        let statusFrame = CGRect(x: statusX, y: 63, width: statusSize.width, height: 14)
                        if let statusApply = statusApply {
                            if self.dateAndStatusNode.supernode == nil {
                               self.addSubnode(self.dateAndStatusNode)
                            }
                            
                            self.dateAndStatusNode.frame = statusFrame
                            statusApply(false)
                        } else if self.dateAndStatusNode.supernode != nil {
                            self.dateAndStatusNode.removeFromSupernode()
                        }
                        
                        if let iconFrame = iconFrame {
                            let iconNode: ASImageNode
                            if let current = self.iconNode {
                                iconNode = current
                            } else {
                                iconNode = ASImageNode()
                                self.iconNode = iconNode
                                self.iconNode?.image = UIImage(bundleImageName: "Chat/\(iconName)")
                                self.insertSubnode(iconNode, at: 0)
                                
                            }
                            iconNode.frame = iconFrame
                        } else if let iconNode = self.iconNode {
                            iconNode.removeFromSupernode()
                            self.iconNode = nil
                        }
                    })
                })
            })
        }
    }
    
    private func updateStatus(animated: Bool) {
        
    }
    
    static func asyncLayout( _ node: ChatMessageInteractiveExchangeNode?) -> (_ item: ChatMessageBubbleContentItem, _ context: AccountContext, _ presentationData: ChatPresentationData, _ message: Message,_ file: TelegramMediaExchange?, _ incoming: Bool,_ dateAndStatusType: ChatMessageDateAndStatusType?, _ constrainedSize: CGSize) -> (CGFloat, (CGSize) -> (CGFloat, (CGFloat) -> (CGSize, (Bool) -> ChatMessageInteractiveExchangeNode))) {
        let currentAsyncLayout = node?.asyncLayout()
        return {item ,context, presentationData, message, file, incoming, dateAndStatusType ,constrainedSize in
            var exchangeNode: ChatMessageInteractiveExchangeNode
            var fileLayout: (_ item: ChatMessageBubbleContentItem ,_ context: AccountContext, _ presentationData: ChatPresentationData, _ message: Message, _ file: TelegramMediaExchange?, _ incoming: Bool, _ dateAndStatusType: ChatMessageDateAndStatusType?,_ constrainedSize: CGSize) -> (CGFloat, (CGSize) -> (CGFloat, (CGFloat) -> (CGSize, (Bool) -> Void)))
            
            if let node = node, let currentAsyncLayout = currentAsyncLayout {
                exchangeNode = node
                fileLayout = currentAsyncLayout
            } else {
                exchangeNode = ChatMessageInteractiveExchangeNode()
                fileLayout = exchangeNode.asyncLayout()
            }
            
            let (initialWidth, continueLayout) = fileLayout(item, context, presentationData, message, file, incoming, dateAndStatusType,constrainedSize)
            
            return (initialWidth, { constrainedSize in
                let (finalWidth, finalLayout) = continueLayout(constrainedSize)
                
                return (finalWidth, { boundingWidth in
                    let (finalSize, apply) = finalLayout(boundingWidth)
                    
                    return (finalSize, { synchronousLoads in
                        apply(synchronousLoads)
                        return exchangeNode
                    })
                })
            })
        }
    }
    
}
