//
//  ChatMessageTranslateNode.swift
//  TelegramUI
//
//  Created by apple on 2020/1/9.
//  Copyright © 2020 Telegram. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Postbox
import Display
import SwiftSignalKit
import class SwiftSignalKit.Signal
import class SwiftSignalKit.Timer
import class SwiftSignalKit.Bag
import class SwiftSignalKit.Queue
import enum SwiftSignalKit.NoError
import protocol SwiftSignalKit.Disposable
import TelegramPresentationData
import ChatTitleActivityNode

private let dateFont = UIFont.italicSystemFont(ofSize: 11.0)
private let translateFont = UIFont.italicSystemFont(ofSize: 16.0)

private func maybeAddRotationAnimation(_ layer: CALayer, duration: Double) {
    if let _ = layer.animation(forKey: "clockFrameAnimation") {
        return
    }
    
    let basicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
    basicAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    basicAnimation.duration = duration
    basicAnimation.fromValue = NSNumber(value: Float(0.0))
    basicAnimation.toValue = NSNumber(value: Float(Double.pi * 2.0))
    basicAnimation.repeatCount = Float.infinity
    basicAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
    basicAnimation.beginTime = 1.0
    layer.add(basicAnimation, forKey: "clockFrameAnimation")
}

enum ChatMessageTranslateType:Int, Equatable {
    case Unknow = 0
    case Loading
    case Success
    case Failed
    
    static func ==(lhs: ChatMessageTranslateType, rhs: ChatMessageTranslateType) -> Bool {
        switch lhs {
            case Success:
                if case .Success = rhs {
                    return true
                } else {
                    return false
                }
            case .Loading:
                if case .Loading = rhs {
                    return true
                } else {
                    return false
                }
            case .Failed:
                if case .Failed = rhs {
                    return true
                } else {
                    return false
                }
            case .Unknow:
                if case .Unknow = rhs {
                    return true
                } else {
                    return false
                }
        }
    }
}

class ChatMessageTranslateNode: ASDisplayNode {
    private let translateTextNode: TextNode
    private let lineNode: ASImageNode
    private let activityNode: ChatTitleActivityNode
    private var type: ChatMessageTranslateType?
    private var theme: ChatPresentationThemeData?
    
    override init() {
        
        self.translateTextNode = TextNode()
        self.translateTextNode.isUserInteractionEnabled = false
        self.translateTextNode.displaysAsynchronously = true
        
        self.lineNode = ASImageNode()
        self.lineNode.displaysAsynchronously = false
        self.lineNode.displayWithoutProcessing = true
        self.lineNode.isLayerBacked = true
        
        self.activityNode = ChatTitleActivityNode()
        
        super.init()
        self.isUserInteractionEnabled = false
        self.addSubnode(self.translateTextNode)
        self.addSubnode(self.lineNode)
        self.addSubnode(self.activityNode)
    }
    
    func asyncLayout() -> (_ presentationData: ChatPresentationData, _ edited: Bool, _ impressionCount: Int?, _ translateText: String, _ type: ChatMessageTranslateType, _ constrainedSize: CGSize, _ originTextNodeSize: CGSize, _ hlStatusNodeType : HLStatusNodeType) -> (CGSize, (Bool) -> Void) {
        let translateTextLayout = TextNode.asyncLayout(self.translateTextNode)
        
        return { presentationData, edited, impressionCount, translateText, type, constrainedSize,originTextNodeSize,hlStatusNodeType  in
            var translateTextColor: UIColor
            translateTextColor = presentationData.theme.theme.chat.message.incoming.secondaryTextColor
            var state: ChatTitleActivityNodeState = .none
            if type == .Loading {
                state = ChatTitleActivityNodeState.typingText(NSAttributedString(string: ""), translateTextColor)
            }
            var updatedtranslateText = translateText
            if edited {
                updatedtranslateText = "\(presentationData.strings.Conversation_MessageEditedLabel) \(updatedtranslateText)"
            }
            if let impressionCount = impressionCount {
                updatedtranslateText = compactNumericCountString(impressionCount, decimalSeparator: presentationData.dateTimeFormat.decimalSeparator) + " " + updatedtranslateText
            }
            
            let (translate, translateApply) = translateTextLayout(TextNodeLayoutArguments(attributedString: NSAttributedString(string: updatedtranslateText, font: translateFont, textColor: translateTextColor), backgroundColor: nil, maximumNumberOfLines: 0, truncationType: .middle, constrainedSize: CGSize(width: originTextNodeSize.width, height: 5000), alignment: .natural, cutout: nil, insets: UIEdgeInsets()))
            let backgroundInsets = UIEdgeInsets(top: 2.0, left: 7.0, bottom: 2.0, right: 7.0)
            let layoutSize = CGSize(width: translate.size.width, height: translate.size.height + backgroundInsets.top + backgroundInsets.bottom)
            
            return (layoutSize, { [weak self] animated in
                if let strongSelf = self {
                    strongSelf.theme = presentationData.theme
                    strongSelf.type = type
                    
                    let _ = translateApply()
                    strongSelf.lineNode.image = PresentationResourcesChat.chatBubblehorizontalLineTranslateImage(presentationData.theme.theme)
                    strongSelf.lineNode.frame = CGRect(origin: CGPoint(x: 0.0, y: 10.0), size: CGSize(width: originTextNodeSize.width, height: 0.5))
                    
                    let _ = strongSelf.activityNode.transitionToState(state, animation: .none)
                    let size = strongSelf.activityNode.updateLayout(CGSize(width: 80, height: 50), alignment: .left)
                    
                    strongSelf.activityNode.frame = CGRect(origin: CGPoint(x: 0.0, y: strongSelf.lineNode.frame.maxY + 10.0), size: size)
                    
                    if strongSelf.activityNode.transitionToState(state, animation: .slide) {
                    }
                    
                    strongSelf.translateTextNode.frame = CGRect(origin: CGPoint(x: 0.0, y: strongSelf.lineNode.frame.maxY + 10.0), size: layoutSize)
                }
            })
        }
    }
    
    static func asyncLayout(_ node: ChatMessageTranslateNode?) -> (_ presentationData: ChatPresentationData, _ edited: Bool, _ impressionCount: Int?, _ translateText: String, _ type: ChatMessageTranslateType, _ constrainedSize: CGSize, _ originTextNodeSize: CGSize) -> (CGSize, (Bool) -> ChatMessageTranslateNode) {
        let currentLayout = node?.asyncLayout()
        return { presentationData, edited, impressionCount, translateText, type, constrainedSize, originTextNodeSize in
            let resultNode: ChatMessageTranslateNode
            let resultSizeAndApply: (CGSize, (Bool) -> Void)
            if let node = node, let currentLayout = currentLayout {
                resultNode = node
                resultSizeAndApply = currentLayout(presentationData, edited, impressionCount, translateText, type, constrainedSize, originTextNodeSize, .default)
            } else {
                resultNode = ChatMessageTranslateNode()
                resultSizeAndApply = resultNode.asyncLayout()(presentationData, edited, impressionCount, translateText, type, constrainedSize, originTextNodeSize,.default)
            }
            
            return (resultSizeAndApply.0, { animated in
                resultSizeAndApply.1(animated)
                return resultNode
            })
        }
    }
}
