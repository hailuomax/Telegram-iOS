//
//  ChatMenuInputNode.swift
//  TelegramUI
//
//  Created by fan on 2020/3/16.
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
import AccountContext
import SyncCore
import LegacyUI
import TelegramPresentationData
import JYDebug

final class ChatMenuInputNode: ChatInputNode {
    private let context: AccountContext
    // 公开给ChatViewController使用
    let menuNode: ChatMediaInputMenuPane
    
    private var menus: [ChatMediaInputMenu] = []
        
    init(context: AccountContext ) {
        self.context = context
        self.menuNode = ChatMediaInputMenuPane(menus: [], onSelect: {_ in })
        super.init()
        self.addSubnode(self.menuNode)
        self.view.disablesInteractiveTransitionGestureRecognizer = true
    }

    
    override func updateLayout(width: CGFloat, leftInset: CGFloat, rightInset: CGFloat, bottomInset: CGFloat, standardInputHeight: CGFloat, inputHeight: CGFloat, maximumHeight: CGFloat, inputPanelHeight: CGFloat, transition: ContainedViewLayoutTransition, interfaceState: ChatPresentationInterfaceState, deviceMetrics: DeviceMetrics, isVisible: Bool) -> (CGFloat, CGFloat) {
        
        let height: CGFloat = 380
        
        jyPrint(width)
        
        self.backgroundColor = interfaceState.theme.chat.inputPanel.panelBackgroundColor
        self.menuNode.backgroundColor = self.backgroundColor
        transition.updateFrame(node: self.menuNode, frame: CGRect(origin: CGPoint(), size: CGSize(width: width, height: height)))
        
        jyPrint(self.menuNode)
        
        return (height + bottomInset, 0)
    }
    
    func updateData(peer: Peer,editMediaOptions: MessageMediaEditingOptions?, saveEditedPhotos: Bool, presentationData: PresentationData, parentController: LegacyController, initialCaption: String, menuInteraction: HLMenuInteraction) {
        
        factoryMenus(with: peer,editMediaOptions:editMediaOptions )
        
        menuNode.contentView.updateWith(presentationData: presentationData, context: context, peer: peer, editMediaOptions: editMediaOptions, saveEditedPhotos: saveEditedPhotos, allowGrouping: true, theme: presentationData.theme, strings: presentationData.strings, parentController: parentController, initialCaption: initialCaption, menus: menus, onSelect: { type in
            switch type {
            case .shooting:
                menuInteraction.openCamera()
            case .photo:
                menuInteraction.openPhoto()
            case .location:
                menuInteraction.openLocation()
            case .contact:
                menuInteraction.openContact()
            case .file:
                menuInteraction.openFile()
            case .redPacket:
                menuInteraction.openRedPacket()
            case .superRedPacket:
                menuInteraction.openSuperRedRacket()
            case .transfer:
                menuInteraction.openTransfer()
            case .exchange:
                menuInteraction.openExchange()
            case .poll:
                menuInteraction.openPoll()
            }
        }, sendMessagesWithSignals: {
            menuInteraction.sendMessageWithSignal($0, $1)
        }, openGallery: {
            menuInteraction.openGallery()
        }, openMediaPicker: {
            menuInteraction.mediaPickerWillOpen()
        }, closeMediaPicker: {
            menuInteraction.mediaPickerWillClose()
        })
    }
    
    ///组装menus
    private func factoryMenus(with peer: Peer, editMediaOptions: MessageMediaEditingOptions?){
        
        guard menus.count == 0 else {return}
        
        var channelGroup = false
               if let tmp = peer as? TelegramChannel { //有可能是一个与频道绑定的群
                   switch tmp.info {
                   case .group:
                       channelGroup = true
                   case .broadcast:
                       channelGroup = false
                   }
               }
        if peer is TelegramUser || peer is TelegramSecretChat || peer is TelegramGroup || channelGroup{
            if peer is TelegramGroup || channelGroup {
                menus.append(.superRedPacket)
            }
            
            //只有在个人聊天，私密聊天，群里面才有以下交易功能
            menus += [.redPacket, .exchange]
            
            if peer is TelegramUser {
                menus.append(.transfer)
            }
        }
        
        var bannedSendMedia: (Int32, Bool)?
        var canSendPolls = true
        if let channel = peer as? TelegramChannel {
            if let value = channel.hasBannedPermission(.banSendMedia) {
                bannedSendMedia = value
            }
            if channel.hasBannedPermission(.banSendPolls) != nil {
                canSendPolls = false
            }
        } else if let group = peer as? TelegramGroup {
            if group.hasBannedPermission(.banSendMedia) {
                bannedSendMedia = (Int32.max, false)
            }
            if group.hasBannedPermission(.banSendPolls) {
                canSendPolls = false
            }
        }
        if editMediaOptions == nil, bannedSendMedia != nil{
            
            menus += [.location,.contact]
            if canSendPolls {
                menus.append(.poll)
            }
            return
        }
        
        
        var editing = false
        var canEditCurrent = false
        if let editMediaOptions = editMediaOptions {
            canEditCurrent = true
            if editMediaOptions.contains(.imageOrVideo) {
                
                editing = true
            }
        }
        
        menus += [.shooting, .photo, ]
        
        
        if !editing || canEditCurrent {
            menus.append(.file)
        }
        if editMediaOptions == nil {
            menus += [.location,.contact]
            if (peer is TelegramGroup || peer is TelegramChannel) && canSendMessagesToPeer(peer) {
                menus.append(.poll)
            }
        }
        
        menus = menus.sorted(by: {return $0.index() < $1.index()})
        
    }
    
    
}
