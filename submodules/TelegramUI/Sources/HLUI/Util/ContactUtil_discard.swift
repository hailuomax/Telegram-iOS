////
////  ContactUtil.swift
////  TelegramUI
////
////  Created by apple on 2019/11/4.
////  Copyright © 2019 Telegram. All rights reserved.
////
//
//import Foundation
//import Postbox
//import TelegramCore
//import SwiftSignalKit
//import AccountContext
//import ChatListUI
//import SyncCore
//import TelegramPresentationData
//import TelegramUIPreferences
//
//public class ContactUtil {
//
//    /// 获取聊天列表的所有数据
//    /// - Parameter context: 上下文
//    /// - Parameter state: 鬼才知道
//    /// - Parameter complete: 回调
//    public static func getAllChatList(context:AccountContext,state: ChatListNodeState,complete: @escaping (([ChatListNodeEntry]?) -> Void)) {
//        _ = (context.account.viewTracker.aroundChatListView(groupId: PeerGroupId.root, index: ChatListIndex.absoluteUpperBound, count: 80)
//        |> map { view, updateType -> [ChatListNodeEntry] in
//            var result: [ChatListNodeEntry] = []
//            let entries = view.entries
//            loop: for entry in entries {
//                switch entry {
//                    case let .MessageEntry(index, message, combinedReadState, isRemovedFromTotalUnreadCount, embeddedState, peer, peerPresence, summaryInfo, hasFailed, isContact):
//                        let updatedMessage = message
//                        let updatedCombinedReadState = combinedReadState
//                        result.append(.PeerEntry(index: offsetPinnedIndex(index, offset: 0), presentationData: state.presentationData, message: updatedMessage, readState: updatedCombinedReadState, isRemovedFromTotalUnreadCount: isRemovedFromTotalUnreadCount, embeddedInterfaceState: embeddedState, peer: peer, presence: peerPresence, summaryInfo: summaryInfo, editing: state.editing, hasActiveRevealControls: index.messageIndex.id.peerId == state.peerIdWithRevealedOptions, selected: state.selectedPeerIds.contains(index.messageIndex.id.peerId), inputActivities: state.peerInputActivities?.activities[index.messageIndex.id.peerId], promoInfo: nil, hasFailedMessages: hasFailed, isContact: isContact))
//                    case let .HoleEntry(hole):
//                        result.append(.HoleEntry(hole, theme: state.presentationData.theme))
//                }
//            }
//            return result
//        }
//        |> deliverOnMainQueue).start(next: { (entries) in
//            complete(entries)
//        })
//    }
//
//    /// 获取聊天列表频道数据
//    /// - Parameter context: 上下文
//    /// - Parameter state: 暂不知道
//    /// - Parameter complete: 回调
//    public static func getGroup(_ context: AccountContext, state: ChatListNodeState,complete: @escaping (([Peer]?) -> Void)) {
//        getAllChatList(context: context, state: state) { (entries) in
//            var peerArr: [Peer] = [Peer]()
//
//            let groupResults = filter(context, entries, .peers(filter: .onlyGroups ,isSelecting: false, additionalCategories: []))
//            if let entries = groupResults {
//                for entry in entries {
//                    switch entry {
//                        case let .PeerEntry(_, _, _, _, _, _, peer, _, _, _, _, _, _, _, _, _):
//                            if let peer = peer.chatMainPeer {
//                                peerArr.append(peer)
//                            }
//                        default:
//                            break
//                    }
//                }
//            }
//
//            let channelResult = filter(context, entries, .peers(filter: .onlyChannels, isSelecting: false, additionalCategories: []))
//            channelResult?.compactMap{$0}
//                .forEach{
//                    switch $0{
//                    case let .PeerEntry(_, _, _, _, _, _, peer, _, _, _, _, _, _, _, _, _):
//                        if let peer = peer.chatMainPeer {
//                            peerArr.append(peer)
//                        }
//                    default: break
//                    }
//            }
//
//            complete(peerArr)
//        }
//    }
//
//    /// 获取聊天列表频道数据
//    /// - Parameter context: 上下文
//    /// - Parameter presentationData: presentationData
//    /// - Parameter complete: 回调
//    public static func getGroup(_ context: AccountContext, presentationData:PresentationData ,complete: @escaping (([Peer]?) -> Void)) {
//        let pData = ChatListPresentationData(theme: presentationData.theme, fontSize: PresentationFontSize.regular, strings: presentationData.strings, dateTimeFormat: presentationData.dateTimeFormat, nameSortOrder: presentationData.nameSortOrder, nameDisplayOrder: presentationData.nameDisplayOrder, disableAnimations: presentationData.disableAnimations)
//
//        let currentState = ChatListNodeState(presentationData: pData, editing: false, peerIdWithRevealedOptions: nil, selectedPeerIds: Set(), selectedAdditionalCategoryIds: Set(), peerInputActivities: nil, pendingRemovalPeerIds: Set(), pendingClearHistoryPeerIds: Set(), archiveShouldBeTemporaryRevealed: false, hiddenPsaPeerId: nil)
//
//        return ContactUtil.getGroup(context, state:currentState, complete: complete )
//    }
//
//    /// 获取聊天列表频道数据
//    /// - Parameter context: 上下文
//    /// - Parameter state: 暂不了解
//    /// - Parameter complete: 筛选出来的回调数据
//    static func getChannel(_ context: AccountContext, state: ChatListNodeState,complete: @escaping (([Peer]?) -> Void)) {
//        getAllChatList(context: context, state: state) { (entries) in
//            let results = filter(context, entries, .peers(filter: .onlyChannels, isSelecting: false, additionalCategories: []))
//            var peerArr: [Peer] = [Peer]()
//            if let entries = results {
//                for entry in entries {
//                    switch entry {
//                    case let .PeerEntry(_, _, _, _, _, _, peer, _, _, _, _, _, _, _, _, _):
//                        if let peer = peer.chatMainPeer {
//                            peerArr.append(peer)
//                        }
//                    default:
//                        break
//                    }
//                }
//            }
//            complete(peerArr)
//        }
//    }
//
//    /// 对聊天列表的数据进行筛选
//    /// - Parameter context: 上下文
//    /// - Parameter rawEntries: 聊天列表的所有数据列表
//    /// - Parameter mode: 模型--分为聊天列表所有数据和需要筛选的
//    private static func filter(_ context: AccountContext, _ rawEntries: [ChatListNodeEntry]?, _ mode: ChatListNodeMode) -> [ChatListNodeEntry]? {
//        guard let rawEntries = rawEntries else { return nil }
//        let entries = rawEntries.filter { entry in
//            switch entry {
//            case let .PeerEntry(_, _, _, _, _, _, peer, _, _, _, _, _, _, _, _, _):
//                switch mode {
//                    case .chatList:
//                        return true
//                    case let .peers(filter , isSelect, _):
//                        guard !filter.contains(.excludeSavedMessages) || peer.peerId != context.account.peerId else { return false }
//                        guard !filter.contains(.excludeSecretChats) || peer.peerId.namespace != Namespaces.Peer.SecretChat else { return false }
//                        guard !filter.contains(.onlyPrivateChats) || peer.peerId.namespace == Namespaces.Peer.CloudUser else { return false }
//
//                        if filter.contains(.onlyGroups) {
//                            var isGroup: Bool = false
//                            if let peer = peer.chatMainPeer as? TelegramChannel, case .group = peer.info {
//                                isGroup = true
//                            } else if peer.peerId.namespace == Namespaces.Peer.CloudGroup {
//                                isGroup = true
//                            }
//                            if !isGroup {
//                                return false
//                            }
//                        }
//
//                        if filter.contains(.onlyChannels) {
//                            if let peer = peer.chatMainPeer as? TelegramChannel, case .broadcast = peer.info {
//                                return true
//                            } else {
//                                return false
//                            }
//                        }
//
//                        if filter.contains(.onlyWriteable) && filter.contains(.excludeDisabled) {
//                            if let peer = peer.peers[peer.peerId] {
//                                if !canSendMessagesToPeer(peer) {
//                                    return false
//                                }
//                            } else {
//                                return false
//                            }
//                        }
//
//                        return true
//                    }
//                default:
//                    return true
//            }
//        }
//        return entries
//    }
//
//    private static func offsetPinnedIndex(_ index: ChatListIndex, offset: UInt16) -> ChatListIndex {
//        if let pinningIndex = index.pinningIndex {
//            return ChatListIndex(pinningIndex: pinningIndex + offset, messageIndex: index.messageIndex)
//        } else {
//            return index
//        }
//    }
//
//}
//
//
