//
//  GroupAndChannelVC.swift
//  TelegramUI
//
//  Created by apple on 2019/10/8.
//  Copyright © 2019 Telegram. All rights reserved.
//

import UIKit
import Foundation
import Postbox
import SwiftSignalKit
import Display
import TelegramCore
import TelegramPresentationData
import TelegramUIPreferences
import HLBase
import ChatListUI
import AccountContext
import TelegramNotices
import HL
import Config
import Language
import SyncCore

public class ContactViewController: BaseVC {
    
    // 联系人vc
    private let groupVC : GroupVC
    private let channelVC : ChannelVC
    public let groupId: PeerGroupId
    
    private let controlsHistoryPreload: Bool
    
    private let viewProcessingQueue = Queue()
    private(set) var currentState: ChatListNodeState
    private let statePromise: ValuePromise<ChatListNodeState>
    var state: Signal<ChatListNodeState, NoError> {
        return self.statePromise.get()
    }
    
    private var currentLocation: ChatListNodeLocation?
    private let chatListLocation = ValuePromise<ChatListNodeLocation>()
    
    
    public init(context: AccountContext, groupId: PeerGroupId, controlsHistoryPreload: Bool, hideNetworkActivityStatus: Bool = false,presentationData:PresentationData) {
        self.groupId = groupId
        self.controlsHistoryPreload = controlsHistoryPreload
        let pData = ChatListPresentationData(theme: presentationData.theme, fontSize: PresentationFontSize.regular, strings: presentationData.strings, dateTimeFormat: presentationData.dateTimeFormat, nameSortOrder: presentationData.nameSortOrder, nameDisplayOrder: presentationData.nameDisplayOrder, disableAnimations: presentationData.disableAnimations)
        
        self.currentState = ChatListNodeState(presentationData: pData, editing: false, peerIdWithRevealedOptions: nil, selectedPeerIds: Set(), selectedAdditionalCategoryIds: Set(), peerInputActivities: nil, pendingRemovalPeerIds: Set(), pendingClearHistoryPeerIds: Set(), archiveShouldBeTemporaryRevealed: false, hiddenPsaPeerId: nil)

        self.statePromise = ValuePromise(self.currentState, ignoreRepeated: true)
        
        self.groupVC = GroupVC(context: context)
        self.channelVC = ChannelVC(context: context)
        
        super.init(context: context)
        
        
        let viewProcessingQueue = self.viewProcessingQueue
        
        
        let displayArchiveIntro: Signal<Bool, NoError>
        if Namespaces.PeerGroup.archive == groupId {
            displayArchiveIntro = context.sharedContext.accountManager.noticeEntry(key: ApplicationSpecificNotice.archiveIntroDismissedKey())
            |> map { entry -> Bool in
                if let value = entry.value as? ApplicationSpecificVariantNotice {
                    return !value.value
                } else {
                    return true
                }
            }
            |> take(1)
            |> afterNext { value in
                Queue.mainQueue().async {
                    if value {
                        let _ = (context.sharedContext.accountManager.transaction { transaction -> Void in
                            ApplicationSpecificNotice.setArchiveIntroDismissed(transaction: transaction, value: true)
                        }).start()
                    }
                }
            }
        } else {
            displayArchiveIntro = .single(false)
        }

        let currentPeerId: PeerId = context.account.peerId
        
        let initialLocation: ChatListNodeLocation  = .initial(count: 200, filter: nil)
        self.setChatListLocation(initialLocation)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setNavigationBar(animated)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func initUI() {

        ContactUtil.getGroup(self.context, state: self.currentState) { (peers) in
            guard let peers = peers else { return }

            var tgGroup = peers.compactMap{$0 as? TelegramGroup}

            peers
                .compactMap{$0 as? TelegramChannel}
                .filter{
                    switch $0.info {
                    case .broadcast:
                        return false
                    case .group:
                        return true
                    }}
                .forEach{
                    var role : TelegramGroupRole!
                    if $0.flags ==  TelegramChannelFlags.isCreator{
                        role = .creator(rank: nil)
                    }else if $0.adminRights != nil{
                        role = .admin(TelegramChatAdminRights(flags: TelegramChatAdminRightsFlags(rawValue: 0)), rank: nil)
                    }else{
                        role = .member
                    }

                    let group = TelegramGroup(id: $0.id, title: $0.title, photo: [], participantCount: 0, role: role, membership: TelegramGroupMembership.Member, flags: TelegramGroupFlags.init(rawValue: 0), defaultBannedRights: nil, migrationReference: nil, creationDate: 0, version: 0)
                    tgGroup.append(group)
            }


            self.groupVC.groupAry.accept(tgGroup)
        }

        ContactUtil.getChannel(self.context, state: self.currentState) { (peers) in
            guard let peers = peers else {return}

            self.channelVC.groupAry.onNext(peers.compactMap{$0 as? TelegramChannel})
        }
        ConfigUI()
    }
    
    
    // UI配置
    private func ConfigUI() {
        // 群
        groupVC.title = HLLanguage.Group2.localized()
        // 频道
        channelVC.title = HLLanguage.Channel.localized()
        let VCs: [UIViewController] = [groupVC, channelVC]
        
        let sv = IMSegmentView(frame: CGRect(x: 0, y: NavBarHeight, width: kScreenWidth, height: kScreenHeight - NavBarHeight), viewControllers: VCs).then{
            $0.didSelectedSegmentAtIndexBlock = { _ in}
            $0.disablesInteractiveTransitionGestureRecognizer = true
        }
        view.addSubview(sv)
    }
        
    func updateState(_ f: (ChatListNodeState) -> ChatListNodeState) {
        let state = f(self.currentState)
        if state != self.currentState {
            self.currentState = state
            self.statePromise.set(state)
        }
    }
    
    private func setChatListLocation(_ location: ChatListNodeLocation) {
        self.currentLocation = .initial(count: 200, filter: nil)
        self.chatListLocation.set(.initial(count: 200, filter: nil))
    }
    
}

extension ContactViewController: NavigationBarType {

    public var titleView : UIView {
        return createTitleViewWith(HLLanguage.GroupsAndChannels.localized())
    }
    
    public var nvBackGroundColor: UIColor{
        return UIColor.hex(.kGrayBackground)
    }
}
