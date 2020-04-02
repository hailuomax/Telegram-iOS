//
//  ChatMenuInputNode.swift
//  TelegramUI
//
//  Created by lemon on 2020/3/16.
//  Copyright © 2020 Telegram. All rights reserved.
//

import Foundation
import UIKit
import Display
import AsyncDisplayKit
import Postbox
import TelegramCore
import SwiftSignalKit
import class SwiftSignalKit.Signal
import class SwiftSignalKit.Timer
import class SwiftSignalKit.Bag
import class SwiftSignalKit.Queue
import enum SwiftSignalKit.NoError
import protocol SwiftSignalKit.Disposable
import TelegramPresentationData
import AccountContext
 
final class ChatMenuInputNode: ChatInputNode {
    private let context: AccountContext
//    private let controllerInteraction: ChatControllerInteraction
    // 公开给ChatViewController使用
//    let menuNode: ChatMediaInputMenuPane
    
    init(context: AccountContext ) {
        self.context = context
//        self.menuNode = ChatMediaInputMenuPane(menus: [], onSelect: {_ in })

        super.init()
//        self.addSubnode(self.menuNode)
        self.view.disablesInteractiveTransitionGestureRecognizer = true
    }

    
    override func updateLayout(width: CGFloat, leftInset: CGFloat, rightInset: CGFloat, bottomInset: CGFloat, standardInputHeight: CGFloat, inputHeight: CGFloat, maximumHeight: CGFloat, inputPanelHeight: CGFloat, transition: ContainedViewLayoutTransition, interfaceState: ChatPresentationInterfaceState, deviceMetrics: DeviceMetrics, isVisible: Bool) -> (CGFloat, CGFloat) {
        
        self.backgroundColor = interfaceState.theme.chat.inputPanel.panelBackgroundColor
//        self.menuNode.backgroundColor = self.backgroundColor
//        transition.updateFrame(node: self.menuNode, frame: CGRect(origin: CGPoint(), size: CGSize(width: width, height: standardInputHeight)))
        
        return (380 + bottomInset, 0)
    }
    
    
}
