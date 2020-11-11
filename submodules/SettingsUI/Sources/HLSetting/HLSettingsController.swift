//
//  HLSettingsController.swift
//  TelegramUI#shared
//
//  Created by fan on 2020/4/13.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Display
import SwiftSignalKit
import Postbox
import TelegramCore
import SyncCore
import LegacyComponents
import MtProtoKit
import TelegramPresentationData
import TelegramUIPreferences
import DeviceAccess
import ItemListUI
import PresentationDataUtils
import AccountContext
import OverlayStatusController
import AvatarNode
import AlertUI
import TelegramNotices
import GalleryUI
import LegacyUI
import PassportUI
import SearchUI
import ItemListPeerItem
import CallListUI
import ChatListUI
import ItemListAvatarAndNameInfoItem
import ItemListPeerActionItem
import WebSearchUI
import PeerAvatarGalleryUI
import MapResourceToAvatarSizes
import AppBundle
import ContextUI
#if ENABLE_WALLET
import WalletUI
#endif
import PhoneNumberFormat
import AccountUtils
import AuthTransferUI
import Account
import Language
import Config
import UI
import Repo
import protocol SwiftSignalKit.Disposable
import ViewModel
import Model
import RxSwift
import HLBase
import Network
import Extension

private let avatarFont = avatarPlaceholderFont(size: 13.0)

private final class ContextControllerContentSourceImpl: ContextControllerContentSource {
    let controller: ViewController
    weak var sourceNode: ASDisplayNode?
    
    let navigationController: NavigationController? = nil
    
    let passthroughTouches: Bool = false
    
    init(controller: ViewController, sourceNode: ASDisplayNode?) {
        self.controller = controller
        self.sourceNode = sourceNode
    }
    
    func transitionInfo() -> ContextControllerTakeControllerInfo? {
        let sourceNode = self.sourceNode
        return ContextControllerTakeControllerInfo(contentAreaInScreenSpace: CGRect(origin: CGPoint(), size: CGSize(width: 10.0, height: 10.0)), sourceNode: { [weak sourceNode] in
            if let sourceNode = sourceNode {
                return (sourceNode, sourceNode.bounds)
            } else {
                return nil
            }
        })
    }
    
    func animatedIn() {
    }
}

private indirect enum SettingsEntryTag: Equatable, ItemListItemTag {
    case account(AccountRecordId)
    
    func isEqual(to other: ItemListItemTag) -> Bool {
        if let other = other as? SettingsEntryTag {
            return self == other
        } else {
            return false
        }
    }
}

private final class SettingsItemArguments {
    let sharedContext: SharedAccountContext
    let avatarAndNameInfoContext: ItemListAvatarAndNameInfoItemContext
    
    let avatarTapAction: () -> Void
    let openEditing: () -> Void
    let displayCopyContextMenu: () -> Void
    let changeProfilePhoto: () -> Void
    let openUsername: () -> Void
    let openMyWallet: () -> Void
    let openAuthentication: () -> Void
    let openLoginPassword: () -> ()
    let openTradePassword: () -> Void
    let openProxy: () -> Void
    let openInvite: (Peer?) -> Void
    let openSetting: () -> Void
    let openAboutMe: () -> Void
    let openQRCode: (Peer?) -> Void
    let openCaiLuCloudCollege: () -> ()
    let openNoticeCenter: (Bool) -> ()
    let openSystemMessages: () -> ()
    ///跳转交易账户页面
    let openBiluAccount: () -> ()
    
    init(
        sharedContext: SharedAccountContext,
        avatarAndNameInfoContext: ItemListAvatarAndNameInfoItemContext,
        avatarTapAction: @escaping () -> Void,
        openEditing: @escaping () -> Void,
        displayCopyContextMenu:@escaping () -> Void,
        changeProfilePhoto:@escaping () -> Void,
        openUsername:@escaping () -> Void,
        openMyWallet:@escaping () -> Void,
        openAuthentication:@escaping () -> Void,
        openLoginPassword: @escaping () -> (),
        openTradePassword:@escaping () -> Void,
        openProxy:@escaping () -> Void,
        openInvite:@escaping (Peer?)-> Void,
        openSetting:@escaping () -> Void,
        openAboutMe:@escaping () -> Void,
        openQRCode:@escaping (Peer?) -> Void,
        openCaiLuCloudCollege:@escaping () -> (),
        openNoticeCenter:@escaping (Bool) -> (),
        openSystemMessages:@escaping () -> (),
        openBiluAccount: @escaping ()->()
    ) {
        self.sharedContext = sharedContext
        self.avatarAndNameInfoContext = avatarAndNameInfoContext
        
        self.avatarTapAction = avatarTapAction
        self.openEditing = openEditing
        self.displayCopyContextMenu = displayCopyContextMenu
        self.changeProfilePhoto = changeProfilePhoto
        self.openUsername = openUsername
        self.openMyWallet = openMyWallet
        self.openAuthentication = openAuthentication
        self.openTradePassword = openTradePassword
        self.openLoginPassword = openLoginPassword
        self.openProxy = openProxy
        self.openInvite = openInvite
        self.openSetting = openSetting
        self.openAboutMe = openAboutMe
        self.openQRCode = openQRCode
        self.openCaiLuCloudCollege = openCaiLuCloudCollege
        self.openNoticeCenter = openNoticeCenter
        self.openSystemMessages = openSystemMessages
        self.openBiluAccount = openBiluAccount
    }
}

private enum SettingsSection: Int32 {
    case info
    case wallet
    case task
    case settings
}

private indirect enum SettingsEntry: ItemListNodeEntry {
    case userInfo(Account, PresentationTheme, PresentationStrings, PresentationDateTimeFormat, Peer?, CachedPeerData?, ItemListAvatarAndNameInfoItemState, ItemListAvatarAndNameInfoItemUpdatingAvatar?)
    
    ///海螺钱包
    case myWallet(PresentationTheme, UIImage?, String ,String)
    ///币路交易账户
    case biluAccount(PresentationTheme, UIImage?, String)
    
    case authentication(PresentationTheme,UIImage?, String, String)
    case loginPassword(PresentationTheme,UIImage?, String, String)
    case tradePassword(PresentationTheme,UIImage?, String, String)
    case inviteFriends(PresentationTheme,UIImage?, String, Peer?)
    case proxy(PresentationTheme, UIImage?, String)
    
    ///财路云学院
    case caiLuCloudCollege(PresentationTheme, UIImage?, String)
    /// 通知中心
    case noticeCenter(PresentationTheme, UIImage?, String, Bool)
    /// 系统消息
    case systemMessage(PresentationTheme, UIImage?, String)
    
    case settings(PresentationTheme, UIImage?, String)
    case aboutMe(PresentationTheme, UIImage?, String, String)
    
    var section: ItemListSectionId {
        switch self {
            case .userInfo:
                return SettingsSection.info.rawValue
        case .myWallet, .biluAccount, .authentication, .loginPassword, .tradePassword, .inviteFriends, .caiLuCloudCollege, .noticeCenter, .systemMessage:
                return SettingsSection.wallet.rawValue
            case .settings, .proxy, .aboutMe:
                return SettingsSection.settings.rawValue
        }
    }
    
    var stableId: Int32 {
        switch self {
        case .userInfo: return 0
        case .myWallet: return 1
        case .biluAccount: return 2
        case .authentication: return 3
        case .loginPassword: return 4
        case .tradePassword: return 5
        case .caiLuCloudCollege: return 6
        case .noticeCenter: return 7
        case .inviteFriends: return 8
        case .systemMessage: return 9
        case .proxy: return 10
        case .settings: return 11
        case .aboutMe: return 12
        }
    }
    
    static func ==(lhs: SettingsEntry, rhs: SettingsEntry) -> Bool {
        switch lhs {
        case let .userInfo(lhsAccount, lhsTheme, lhsStrings, lhsDateTimeFormat, lhsPeer, lhsCachedData, lhsEditingState, lhsUpdatingImage):
            if case let .userInfo(rhsAccount, rhsTheme, rhsStrings, rhsDateTimeFormat, rhsPeer, rhsCachedData, rhsEditingState, rhsUpdatingImage) = rhs {
                if lhsAccount !== rhsAccount {
                    return false
                }
                if lhsTheme !== rhsTheme {
                    return false
                }
                if lhsStrings !== rhsStrings {
                    return false
                }
                if lhsDateTimeFormat != rhsDateTimeFormat {
                    return false
                }
                if let lhsPeer = lhsPeer, let rhsPeer = rhsPeer {
                    //用户名不相等也刷新判断
                    if lhsPeer.addressName != rhsPeer.addressName {
                        return false
                    }
                    if !lhsPeer.isEqual(rhsPeer) {
                        return false
                    }
                } else if (lhsPeer != nil) != (rhsPeer != nil) {
                    return false
                }
                if let lhsCachedData = lhsCachedData, let rhsCachedData = rhsCachedData {
                    if !lhsCachedData.isEqual(to: rhsCachedData) {
                        return false
                    }
                } else if (lhsCachedData != nil) != (rhsCachedData != nil) {
                    return false
                }
                if lhsEditingState != rhsEditingState {
                    return false
                }
                if lhsUpdatingImage != rhsUpdatingImage {
                    return false
                }
                return true
            } else {
                return false
            }
        case let .myWallet(lhsTheme,_,lhsTitle,lhsText):
            if case let .myWallet(rhsTheme,_,rhsTitle,rhsText) = rhs, lhsTheme === rhsTheme, lhsTitle == rhsTitle, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .biluAccount(lhsTheme, _, lhsTitle):
            if case let .biluAccount(rhsTheme, _, rhsTitle) = rhs, lhsTheme === rhsTheme, lhsTitle == rhsTitle{
                return true
            }else{
                return false
            }
        case let .authentication(lhsTheme,_,lhsTitle, lhsText):
            if case let .authentication(rhsTheme,_,rhsTitle, rhsText) = rhs, lhsTheme === rhsTheme, lhsTitle == rhsTitle, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .tradePassword(lhsTheme,_,lhsTitle, lhsText):
            if case let .tradePassword(rhsTheme,_,rhsTitle, rhsText) = rhs, lhsTheme === rhsTheme, lhsTitle == rhsTitle, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .loginPassword(lhsTheme, _, lhsTitle, lhsText):
            if case let .loginPassword(rhsTheme,_,rhsTitle, rhsText) = rhs, lhsTheme === rhsTheme, lhsTitle == rhsTitle, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .proxy(lhsTheme,_,lhsTitle):
            if case let .proxy(rhsTheme,_,rhsTitle) = rhs, lhsTheme === rhsTheme, lhsTitle == rhsTitle {
                return true
            } else {
                return false
            }
        case let .settings(lhsTheme,_,lhsTitle):
            if case let .settings(rhsTheme,_,rhsTitle) = rhs, lhsTheme === rhsTheme, lhsTitle == rhsTitle {
                return true
            } else {
                return false
            }
        case let .inviteFriends(lhsTheme, _, lhsTitle,_):
            if case let .inviteFriends(rhsTheme,_,rhsTitle,_) = rhs, lhsTheme === rhsTheme, lhsTitle == rhsTitle {
                return true
            } else {
                return false
            }
        case let .aboutMe(lhsTheme,_,lhsTitle,lhsText):
            if case let .aboutMe(rhsTheme,_,rhsTitle,rhsText) = rhs, lhsTheme === rhsTheme, lhsTitle == rhsTitle, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .caiLuCloudCollege(lhsTheme, _, lhsTitle):
            if case let .caiLuCloudCollege(rhsTheme,_,rhsTitle) = rhs, lhsTheme === rhsTheme, lhsTitle == rhsTitle {
                return true
            } else {
                return false
            }
        case let .noticeCenter(lhsTheme, _, lhsTitle, lhsUnread):
            if case let .noticeCenter(rhsTheme, _, rhsTitle, rhsUnread) = rhs,  lhsTheme === rhsTheme, lhsTitle == rhsTitle , lhsUnread == rhsUnread {
                return true
            }else {
                return false
            }
            
        case let .systemMessage(lhsTheme, _, lhsTitle):
            if case let .systemMessage(rhsTheme, _, rhsTitle) = rhs,  lhsTheme === rhsTheme, lhsTitle == rhsTitle {
                return true
            }else {
                return false
            }
        }
    }
    
    static func <(lhs: SettingsEntry, rhs: SettingsEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }
    
    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! SettingsItemArguments
        switch self {
            case let .userInfo(account, theme, strings, dateTimeFormat, peer, cachedData, state, updatingImage):
                return ItemListAvatarAndNameInfoItem(accountContext: arguments.sharedContext.makeTempAccountContext(account: account), presentationData: presentationData, dateTimeFormat: dateTimeFormat, mode: .settings, peer: peer, presence: TelegramUserPresence(status: .present(until: Int32.max), lastActivity: 0), cachedData: cachedData, state: state, sectionId: ItemListSectionId(self.section), style: .blocks(withTopInset: false, withExtendedBottomInset: false), editingNameUpdated: { _ in
                }, avatarTapped: {
                    arguments.avatarTapAction()
                }, context: arguments.avatarAndNameInfoContext, updatingImage: updatingImage, action: {
                    arguments.openEditing()
                }, longTapAction: {
                    arguments.displayCopyContextMenu()
                }, qrCodeAction: {
                    arguments.openQRCode(peer)
                })
            
        case let .myWallet(_, image, text , value):
            return ItemListDisclosureItem(presentationData: presentationData, icon: image, title: text, label: value, sectionId: ItemListSectionId(self.section), style: .blocks,action: {
                arguments.openMyWallet()
            }, clearHighlightAutomatically: false)
        
        case let .biluAccount(_, image, text):
            return ItemListDisclosureItem(presentationData: presentationData, icon: image, title: text, label: "", sectionId: ItemListSectionId(self.section), style: .blocks,action: {
                arguments.openBiluAccount()
            })
            
        case let .authentication(_, image, text, value):
            return ItemListDisclosureItem.init(presentationData: presentationData,icon: image , title: text, label: value, sectionId: ItemListSectionId(self.section), style: .blocks , action: {
                arguments.openAuthentication()
            })
        case let .loginPassword(_, image, text, value):
            return ItemListDisclosureItem.init(presentationData: presentationData,icon: image , title: text, label: value, sectionId: ItemListSectionId(self.section), style: .blocks , action: {
                arguments.openLoginPassword()
            })
        case let .tradePassword(_,image, text, value):
            return ItemListDisclosureItem.init(presentationData: presentationData,icon: image , title: text, label: value, sectionId: ItemListSectionId(self.section), style: .blocks , action: {
                arguments.openTradePassword()
            })
        case let .inviteFriends(_, image, title, peer):
            return ItemListDisclosureItem.init(presentationData: presentationData,icon: image , title: title, label: "", sectionId: ItemListSectionId(self.section), style: .blocks , action: {
                arguments.openInvite(peer)
            })
        case let .proxy(_, image, text):
            return ItemListDisclosureItem.init(presentationData: presentationData,icon: image , title: text, label: "", sectionId: ItemListSectionId(self.section), style: .blocks , action: {
                arguments.openProxy()
            })
        case let .settings(_, image, text):
            return ItemListDisclosureItem.init(presentationData: presentationData,icon: image , title: text, label: "", sectionId: ItemListSectionId(self.section), style: .blocks , action: {
                arguments.openSetting()
            })
        case let .aboutMe(_, image, text, value):
            return ItemListDisclosureItem.init(presentationData: presentationData,icon: image , title: text, label: value, sectionId: ItemListSectionId(self.section), style: .blocks , action: {
                arguments.openAboutMe()
            })
        case let .caiLuCloudCollege(_, image, text):
            return ItemListDisclosureItem.init(presentationData: presentationData,icon: image , title: text, label: "", sectionId: ItemListSectionId(self.section), style: .blocks , action: {
                arguments.openCaiLuCloudCollege()
            })
        case let .noticeCenter(_, image, text, unread):
            return ItemListDisclosureItem.init(presentationData: presentationData,icon: image , title: text, label: "", sectionId: ItemListSectionId(self.section),style: .blocks , showRedDot: unread, action: {
                arguments.openNoticeCenter(unread)
            })
        case let .systemMessage(_, image, text):
            return ItemListDisclosureItem.init(presentationData: presentationData,icon: image , title: text, label: "" , sectionId: ItemListSectionId(self.section), style: .blocks , action: {
                arguments.openSystemMessages()
            })
        }
    }
}

private struct SettingsState: Equatable {
    var updatingAvatar: ItemListAvatarAndNameInfoItemUpdatingAvatar?
    var accountIdWithRevealedOptions: AccountRecordId?
    var isSearching: Bool
    var unread: Bool
}

//MARK: 配置Entries
private func settingsEntries(account: Account, presentationData: PresentationData, state: SettingsState, view: PeerView, proxySettings: ProxySettings, notifyExceptions: NotificationExceptionsList?, notificationsAuthorizationStatus: AccessType, notificationsWarningSuppressed: Bool, unreadTrendingStickerPacks: Int, archivedPacks: [ArchivedStickerPackItem]?, privacySettings: AccountPrivacySettings?, hasWallet: Bool, hasPassport: Bool, hasWatchApp: Bool, accountsAndPeers: [(Account, Peer, Int32)], inAppNotificationSettings: InAppNotificationSettings, experimentalUISettings: ExperimentalUISettings, displayPhoneNumberConfirmation: Bool, otherSessionCount: Int, enableQRLogin: Bool, enableFilters: Bool) -> [SettingsEntry] {
    var entries: [SettingsEntry] = []
    
    if let peer = peerViewMainPeer(view) as? TelegramUser {
        let userInfoState = ItemListAvatarAndNameInfoItemState(editingName: nil, updatingName: nil)
        entries.append(.userInfo(account, presentationData.theme, presentationData.strings, presentationData.dateTimeFormat, peer, view.cachedData, userInfoState, state.updatingAvatar))
        
        let phones = AccountRepo.getAccountPhone()
        entries.append(.myWallet(presentationData.theme, PresentationResourcesSettings.myWallet, HLLanguage.MyAssets.localized(), phones.phone))
        
        let user = HLAccountManager.shareAccount
        
        if  HLAccountManager.walletIsLogined {
            
            entries.append(.biluAccount(presentationData.theme, UIImage(bundleImageName: "BiluAsset"), BiluTransfer.Bilu.str))
            
            //登录密码
            entries.append(.loginPassword(presentationData.theme, PresentationResourcesSettings.accountProtection, HLLanguage.LoginPassword.localized(), HLLanguage.Change.localized()))
            //交易密码
            entries.append(.tradePassword(presentationData.theme, PresentationResourcesSettings.tradePassword, HLLanguage.TransactionPassword.localized(), HLLanguage.Change.localized()))
            
            entries.append(.noticeCenter(presentationData.theme, PresentationResourcesSettings.notificationCenter, Notice.Title.str , state.unread))
            
            //邀請好友
            entries.append(.inviteFriends(presentationData.theme, PresentationResourcesSettings.inviteFriends, HLLanguage.InviteNewUser.localized(), peer))
            
//            entries.append(.caiLuCloudCollege(presentationData.theme, PresentationResourcesSettings.caiLuCloudCollege, "财路云学院"))
            
            
        }
        
//        entries.append(.systemMessage(presentationData.theme, PresentationResourcesSettings.systemNotice, "系统公告"))
        
        entries.append(.proxy(presentationData.theme, UIImage(bundleImageName: "ProxySetting"), HLLanguage.Agent.localized()))
        
        //        entries.append(.task1(presentationData.theme, PresentationResourcesSettings.task1, "任务内容1"))
        //
        //        entries.append(.task2(presentationData.theme, PresentationResourcesSettings.task2, "任务内容2"))
        
        entries.append(.settings(presentationData.theme, PresentationResourcesSettings.setting, HLLanguage.Setup.localized()))
        
        entries.append(.aboutMe(presentationData.theme, PresentationResourcesSettings.aboutMe, HLLanguage.AboutConch.localized(), APPConfig.appVersion))
        
        
    }
    
    //按stableId重新排序
    return entries.sorted {$0.stableId < $1.stableId}
}


private final class SettingsControllerImpl: ItemListController, SettingsController {
    let sharedContext: SharedAccountContext
    let contextValue: Promise<AccountContext>
    var accountsAndPeersValue: ((Account, Peer)?, [(Account, Peer, Int32)])?
    var accountsAndPeersDisposable: Disposable?
    
    var switchToAccount: ((AccountRecordId) -> Void)?
    var addAccount: (() -> Void)?
    
    let disposeBag = DisposeBag()
    
    override var navigationBarRequiresEntireLayoutUpdate: Bool {
        return false
    }

    init(currentContext: AccountContext, contextValue: Promise<AccountContext>, state: Signal<(ItemListControllerState, (ItemListNodeState, Any)), NoError>, tabBarItem: Signal<ItemListControllerTabBarItem, NoError>?, accountsAndPeers: Signal<((Account, Peer)?, [(Account, Peer, Int32)]), NoError>) {
        self.sharedContext = currentContext.sharedContext
        self.contextValue = contextValue
        let presentationData = currentContext.sharedContext.currentPresentationData.with { $0 }
        
        self.contextValue.set(.single(currentContext))
        
        let updatedPresentationData = self.contextValue.get()
        |> mapToSignal { context -> Signal<PresentationData, NoError> in
            return context.sharedContext.presentationData
        }
        
        super.init(presentationData: ItemListPresentationData(presentationData), updatedPresentationData: updatedPresentationData |> map(ItemListPresentationData.init(_:)), state: state, tabBarItem: tabBarItem)
        
        self.tabBarItemContextActionType = .always
        
        self.accountsAndPeersDisposable = (accountsAndPeers
        |> deliverOnMainQueue).start(next: { [weak self] value in
            self?.accountsAndPeersValue = value
        })
        //MARK: -更新用户信息
        if HLAccountManager.walletIsLogined{
            AccountRepo.shared.updateUserInfo().value { (accountM) in
                HLAccountManager.shareAccount = accountM
                if accountM.token == nil || accountM.token!.isEmpty {
                    HLAccountManager.cleanWalletToken()
                } else {
                    if let phoneCode = accountM.phoneCode,let telephone = accountM.telephone {
                        HLAccountManager.sharePhone = "\(phoneCode.replacingOccurrences(of: "+", with: ""))\(telephone)"
                    }
                }
            }.load(disposeBag)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.accountsAndPeersDisposable?.dispose()
    }
    
    func updateContext(context: AccountContext) {
        //self.contextValue.set(.single(context))
    }
    
    /*func presentTabBarPreviewingController(sourceNodes: [ASDisplayNode]) {
        guard let (maybePrimary, other) = self.accountsAndPeersValue, let primary = maybePrimary else {
            return
        }
        let controller = TabBarAccountSwitchController(sharedContext: self.sharedContext, accounts: (primary, other), canAddAccounts: other.count + 1 < maximumNumberOfAccounts, switchToAccount: { [weak self] id in
            self?.switchToAccount?(id)
        }, addAccount: { [weak self] in
            self?.addAccount?()
        }, sourceNodes: sourceNodes)
        self.sharedContext.mainWindow?.present(controller, on: .root)
    }
    
    func updateTabBarPreviewingControllerPresentation(_ update: TabBarContainedControllerPresentationUpdate) {
    }*/
    
    override public func tabBarItemContextAction(sourceNode: ContextExtractedContentContainingNode, gesture: ContextGesture) {
        guard let (maybePrimary, other) = self.accountsAndPeersValue, let primary = maybePrimary else {
            return
        }
        
        let presentationData = self.sharedContext.currentPresentationData.with { $0 }
        let strings = presentationData.strings
        
        var items: [ContextMenuItem] = []
        if other.count + 1 < maximumNumberOfAccounts {
            items.append(.action(ContextMenuActionItem(text: strings.Settings_AddAccount, icon: { theme in
                return generateTintedImage(image: UIImage(bundleImageName: "Chat/Context Menu/Add"), color: theme.contextMenu.primaryColor)
            }, action: { [weak self] _, f in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.addAccount?()
                f(.dismissWithoutContent)
            })))
        }
        
        func accountIconSignal(account: Account, peer: Peer, size: CGSize) -> Signal<UIImage?, NoError> {
            let iconSignal: Signal<UIImage?, NoError>
            if let signal = peerAvatarImage(account: account, peerReference: PeerReference(peer), authorOfMessage: nil, representation: peer.profileImageRepresentations.first, displayDimensions: size, inset: 0.0, emptyColor: nil, synchronousLoad: false) {
                iconSignal = signal
                |> map { imageVersions -> UIImage? in
                    return imageVersions?.0
                }
            } else {
                let peerId = peer.id
                let displayLetters = peer.displayLetters
                iconSignal = Signal { subscriber in
                    let image = generateImage(size, rotatedContext: { size, context in
                        context.clear(CGRect(origin: CGPoint(), size: size))
                        drawPeerAvatarLetters(context: context, size: CGSize(width: size.width, height: size.height), font: avatarFont, letters: displayLetters, peerId: peerId)
                    })?.withRenderingMode(.alwaysOriginal)
                    
                    subscriber.putNext(image)
                    subscriber.putCompletion()
                    return EmptyDisposable
                }
            }
            return iconSignal
        }
        
        let avatarSize = CGSize(width: 28.0, height: 28.0)
        
        items.append(.action(ContextMenuActionItem(text: primary.1.displayTitle(strings: strings, displayOrder: presentationData.nameDisplayOrder), icon: { _ in nil }, iconSource: ContextMenuActionItemIconSource(size: avatarSize, signal: accountIconSignal(account: primary.0, peer: primary.1, size: avatarSize)), action: { _, f in
            f(.default)
        })))
        
        if !other.isEmpty {
            items.append(.separator)
        }
        
        for account in other {
            let id = account.0.id
            items.append(.action(ContextMenuActionItem(text: account.1.displayTitle(strings: strings, displayOrder: presentationData.nameDisplayOrder), badge: account.2 != 0 ? ContextMenuActionBadge(value: "\(account.2)", color: .accent) : nil, icon: { _ in nil }, iconSource: ContextMenuActionItemIconSource(size: avatarSize, signal: accountIconSignal(account: account.0, peer: account.1, size: avatarSize)), action: { [weak self] _, f in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.switchToAccount?(id)
                f(.dismissWithoutContent)
            })))
        }
        
        let controller = ContextController(account: primary.0, presentationData: presentationData, source: .extracted(SettingsTabBarContextExtractedContentSource(controller: self, sourceNode: sourceNode)), items: .single(items), reactionItems: [], recognizer: nil, gesture: gesture)
        self.sharedContext.mainWindow?.presentInGlobalOverlay(controller)
    }
}

private final class SettingsTabBarContextExtractedContentSource: ContextExtractedContentSource {
    let keepInPlace: Bool = true
    let ignoreContentTouches: Bool = true
    
    private let controller: ViewController
    private let sourceNode: ContextExtractedContentContainingNode
    
    init(controller: ViewController, sourceNode: ContextExtractedContentContainingNode) {
        self.controller = controller
        self.sourceNode = sourceNode
    }
    
    func takeView() -> ContextControllerTakeViewInfo? {
        return ContextControllerTakeViewInfo(contentContainingNode: self.sourceNode, contentAreaInScreenSpace: UIScreen.main.bounds)
    }
    
    func putBack() -> ContextControllerPutBackViewInfo? {
        return ContextControllerPutBackViewInfo(contentAreaInScreenSpace: UIScreen.main.bounds)
    }
}

let repo = Repo.Notice()
//MARK: ====HLSettingsController=====
public func hlSettingsController(context: AccountContext, accountManager: AccountManager, enableDebugActions: Bool) -> SettingsController & ViewController {
    
    let initialState = SettingsState(updatingAvatar: nil, accountIdWithRevealedOptions: nil, isSearching: false, unread: false)
    let statePromise = ValuePromise(initialState, ignoreRepeated: true)
    let stateValue = Atomic(value: initialState)
    let updateState: ((SettingsState) -> SettingsState) -> Void = { f in
        statePromise.set(stateValue.modify { f($0) })
    }
    
    var pushControllerImpl: ((ViewController) -> Void)?
    var presentControllerImpl: ((ViewController, Any?) -> Void)?
    var presentInGlobalOverlayImpl: ((ViewController, Any?) -> Void)?
    var dismissInputImpl: (() -> Void)?
    var setDisplayNavigationBarImpl: ((Bool) -> Void)?
    var getNavigationControllerImpl: (() -> NavigationController?)?
    var displayCopyContextMenuImpl: ((Peer) -> Void)?
    
    let actionsDisposable = DisposableSet()
    
    let updateAvatarDisposable = MetaDisposable()
    actionsDisposable.add(updateAvatarDisposable)
    
    let supportPeerDisposable = MetaDisposable()
    actionsDisposable.add(supportPeerDisposable)
    
    let hiddenAvatarRepresentationDisposable = MetaDisposable()
    actionsDisposable.add(hiddenAvatarRepresentationDisposable)
    
    let updatePassportDisposable = MetaDisposable()
    actionsDisposable.add(updatePassportDisposable)
    
    let openEditingDisposable = MetaDisposable()
    actionsDisposable.add(openEditingDisposable)
    
    let currentAvatarMixin = Atomic<TGMediaAvatarMenuMixin?>(value: nil)
    
    var avatarGalleryTransitionArguments: ((AvatarGalleryEntry) -> GalleryTransitionArguments?)?
    let avatarAndNameInfoContext = ItemListAvatarAndNameInfoItemContext()
    var updateHiddenAvatarImpl: (() -> Void)?
    var changeProfilePhotoImpl: (() -> Void)?
    var openSavedMessagesImpl: (() -> Void)?
    
    let archivedPacks = Promise<[ArchivedStickerPackItem]?>()
    
    let contextValue = Promise<AccountContext>()
    let accountsAndPeers = Promise<((Account, Peer)?, [(Account, Peer, Int32)])>()
    accountsAndPeers.set(activeAccountsAndPeers(context: context))
    
    let privacySettings = Promise<AccountPrivacySettings?>(nil)
    
    let enableQRLogin = Promise<Bool>()
    let enableFilters = Promise<Bool>()
    
    let openFaq: (Promise<ResolvedUrl>, String?) -> Void = { resolvedUrl, customAnchor in
        let _ = (contextValue.get()
        |> deliverOnMainQueue
        |> take(1)).start(next: { context in
            let presentationData = context.sharedContext.currentPresentationData.with { $0 }
            let controller = OverlayStatusController(theme: presentationData.theme, type: .loading(cancelled: nil))
            presentControllerImpl?(controller, nil)
            let _ = (resolvedUrl.get()
            |> take(1)
            |> deliverOnMainQueue).start(next: { [weak controller] resolvedUrl in
                controller?.dismiss()

                var resolvedUrl = resolvedUrl
                if case let .instantView(webPage, _) = resolvedUrl, let customAnchor = customAnchor {
                    resolvedUrl = .instantView(webPage, customAnchor)
                }
                context.sharedContext.openResolvedUrl(resolvedUrl, context: context, urlContext: .generic, navigationController: getNavigationControllerImpl?(), openPeer: { peer, navigation in
                }, sendFile: nil, sendSticker: nil, present: { controller, arguments in
                    pushControllerImpl?(controller)
                }, dismissInput: {}, contentContext: nil)
            })
        })
    }
    
    let resolvedUrl = contextValue.get()
    |> deliverOnMainQueue
    |> mapToSignal { context -> Signal<ResolvedUrl, NoError> in
        return cachedFaqInstantPage(context: context)
    }
    
    var removeAccountImpl: ((AccountRecordId) -> Void)?
    var switchToAccountImpl: ((AccountRecordId) -> Void)?
    
    let displayPhoneNumberConfirmation = ValuePromise<Bool>(false)
    
    let activeSessionsContextAndCountSignal = contextValue.get()
    |> deliverOnMainQueue
    |> mapToSignal { context -> Signal<(ActiveSessionsContext, Int, WebSessionsContext), NoError> in
        let activeSessionsContext = ActiveSessionsContext(account: context.account)
        let webSessionsContext = WebSessionsContext(account: context.account)
        let otherSessionCount = activeSessionsContext.state
        |> map { state -> Int in
            return state.sessions.filter({ !$0.isCurrent }).count
        }
        |> distinctUntilChanged
        return otherSessionCount
        |> map { value in
            return (activeSessionsContext, value, webSessionsContext)
        }
    }
    let activeSessionsContextAndCount = Promise<(ActiveSessionsContext, Int, WebSessionsContext)>()
    activeSessionsContextAndCount.set(activeSessionsContextAndCountSignal)
    
    let blockedPeers = Promise<BlockedPeersContext?>(nil)
    let hasTwoStepAuthPromise = Promise<Bool?>(nil)
    
    //MARK: 创建arguments
    let arguments = SettingsItemArguments.init(sharedContext: context.sharedContext, avatarAndNameInfoContext: avatarAndNameInfoContext, avatarTapAction: {
        //MARK: 点击头像
        var updating = false
        updateState {
            updating = $0.updatingAvatar != nil
            return $0
        }
        if updating {
            return
        }
        let _ = (contextValue.get()
        |> deliverOnMainQueue
        |> take(1)).start(next: { context in
            let _ = (context.account.postbox.loadedPeerWithId(context.account.peerId)
            |> take(1)
            |> deliverOnMainQueue).start(next: { peer in
                if peer.smallProfileImage != nil {
                    let galleryController = AvatarGalleryController(context: context, peer: peer, replaceRootController: { controller, ready in
                        
                    })
                    hiddenAvatarRepresentationDisposable.set((galleryController.hiddenMedia |> deliverOnMainQueue).start(next: { entry in
                        avatarAndNameInfoContext.hiddenAvatarRepresentation = entry?.representations.first?.representation
                        updateHiddenAvatarImpl?()
                    }))
                    presentControllerImpl?(galleryController, AvatarGalleryControllerPresentationArguments(transitionArguments: { entry in
                        return avatarGalleryTransitionArguments?(entry)
                    }))
                } else {
                    changeProfilePhotoImpl?()
                }
            })
        })
    }, openEditing: {
        //MARK: 点击设置
        let _ = (contextValue.get()
            |> deliverOnMainQueue
            |> take(1)).start(next: { context in
                if let presentControllerImpl = presentControllerImpl, let pushControllerImpl = pushControllerImpl {
                    openEditingDisposable.set(openEditSettings(context: context, accountsAndPeers: accountsAndPeers.get(), presentController: presentControllerImpl, pushController: pushControllerImpl))
                }
            })
    }, displayCopyContextMenu: {
        //MARK: displayCopyContextMenu
        let _ = (contextValue.get()
            |> deliverOnMainQueue
            |> take(1)).start(next: { context in
                let _ = (context.account.postbox.transaction { transaction -> (Peer?) in
                    return transaction.getPeer(context.account.peerId)
                    }
                    |> deliverOnMainQueue).start(next: { peer in
                        if let peer = peer {
                            displayCopyContextMenuImpl?(peer)
                        }
                    })
            })
    }, changeProfilePhoto: {
        
    }, openUsername: {
        let _ = (contextValue.get()
        |> deliverOnMainQueue
        |> take(1)).start(next: { context in
            presentControllerImpl?(usernameSetupController(context: context), nil)
        })
    }, openMyWallet: {
        //MARK: ===点击资产====
        let _ = (contextValue.get()
        |> deliverOnMainQueue
            |> take(1)).start(next: { context in
                
                let presentationData = context.sharedContext.currentPresentationData.with{$0}
                // 资产首页
                let  assetVC = AssetVC(presentationData: presentationData)
                
                if HLAccountManager.walletIsLogined {
                    pushControllerImpl?(assetVC)
                } else {
                    let pushAccountValidationVC : (Bool, Phone,Bool)->() = { (showPwdView, phone,canLoginWithPwd) in
//                        let vc = AccountValidationVC(phone:phone, context: context,showPwdView: showPwdView, onValidateSuccess: {
//                            //验证成功回调
//                            pushControllerImpl?(assetVC)
//                        })
                        let vc = AccountValidationVC.create(presentationData: presentationData, showPwdView: showPwdView, phone: phone, canLoginWithPwd: canLoginWithPwd) {
                            pushControllerImpl?(assetVC)
                        }
                        pushControllerImpl?(vc)
                    }
                    
                    var currentVC: UIViewController? = nil
                    if let impl = getNavigationControllerImpl,
                        let nv = impl(){
                        currentVC = nv.topViewController
                    }
                    let presentationData = context.sharedContext.currentPresentationData.with({ $0 })
                    AssetVerificationViewController.show(presentationData: presentationData, currentVC: currentVC, onPushAccountLockVC: {
                        let disableVC = AccountLockVC(presentationData: presentationData, title: $0)
                        pushControllerImpl?(disableVC)
                    }, onPushAccountValidationVC: {
                        pushAccountValidationVC($0,$1,$2)
                    }, onPushBindExceptionVC: {
                        let exceptionVM = BindExceptionVM(oldPhoneCode: $0, oldTelephone: $1, payPwdStatus: $2, onValidateSuccess: {})
                        let exceptionVC = $0 == "1" ? BindExceptionPswVC(presentationData: presentationData, viewModel: exceptionVM) : BindExceptionCaptchaVC(presentationData: presentationData, viewModel: exceptionVM)
                        pushControllerImpl?(exceptionVC)
                    })
                }
            })
    }, openAuthentication: {
        //MARK: 实名认证

    }, openLoginPassword:{
        JYPrint("openLoginPassword")
    }, openTradePassword: {
        //MARK: 交易密码
        let _ = (contextValue.get()
        |> deliverOnMainQueue
        |> take(1)).start(next: { context in
            let pwdVC = TradePasswordVC(presentationData: context.sharedContext.currentPresentationData.with{$0}, onPwdSat: nil)
            pushControllerImpl?(pwdVC)

        })
    }, openProxy: {
        //MARK: 代理
        let _ = (contextValue.get()
        |> deliverOnMainQueue
        |> take(1)).start(next: { context in
            pushControllerImpl?(proxySettingsController(context: context))
        })
    }, openInvite: { peer in
        //MARK: 邀请好友
        let _ = (contextValue.get()
        |> deliverOnMainQueue
        |> take(1)).start(next: { context in
            let inviteVC = NewInviteFriendsVC(peer: peer, context: context)
            pushControllerImpl?(inviteVC)
        })
    }, openSetting: {
        //MARK: 设置
        let _ = (contextValue.get()
        |> deliverOnMainQueue
        |> take(1)).start(next: { context in
            let setting = settingsController(context: context, accountManager: context.sharedContext.accountManager, enableDebugActions: enableDebugActions)
            pushControllerImpl?(setting)
        })
    }, openAboutMe: {
        
    }, openQRCode: { peer in
        let _ = (contextValue.get()
        |> deliverOnMainQueue
        |> take(1)).start(next: { context in
            guard let peer = peer else { return }
            if peer.addressName == nil || peer.addressName!.isEmpty   {
                presentControllerImpl?(usernameSetupController(context: context) , nil)
            }else {
                //弹出二维码页面
                let vc = QRCodeViewController(context: context, peerId: peer.id , type: .user)
                pushControllerImpl?(vc)
                
            }
        })
    }, openCaiLuCloudCollege: {
        let _ = (contextValue.get()
            |> deliverOnMainQueue
            |> take(1)).start(next: { context in
                let presentationData = context.sharedContext.currentPresentationData.with{$0}
                
                let webVC: HLBaseVC<BaseWkWebView> = HLBaseVC<BaseWkWebView>(presentationData: presentationData).then{
                    $0.contentView.load(urlStr: "https://m.cailu.net/academy", jsNames: [], onListen: {_,_  in})
                }
                pushControllerImpl?(webVC)
            })
    }, openNoticeCenter: { unread in
        let _ = (contextValue.get()
        |> deliverOnMainQueue
        |> take(1)).start(next: { context in
            let presentationData = context.sharedContext.currentPresentationData.with{$0}
            let vc = NoticeCenterVC(presentationData: presentationData, unread: unread)
            pushControllerImpl?(vc)
        })
        
    }, openSystemMessages: {
        let _ = (contextValue.get()
        |> deliverOnMainQueue
        |> take(1)).start(next: { context in
            let presentationData = context.sharedContext.currentPresentationData.with{$0}
            let vc = SystemMessagesVC(presentationData: presentationData)
            pushControllerImpl?(vc)
        })
    }, openBiluAccount: {
        let _ = (contextValue.get()
                    |> deliverOnMainQueue
                    |> take(1)).start(next: { context in
                        let presentationData = context.sharedContext.currentPresentationData.with{$0}
                        
                        let biluAccountVC: BiluAccountCurrencyListVC = BiluAccountCurrencyListVC(presentationData: presentationData)
                        
                        if HLAccountManager.biLuToken.isEmpty {
                            let logoinVC = TransactionLoginVC(presentationData: presentationData)
                            logoinVC.successBlock = { [weak logoinVC] in
                                logoinVC?.navigationController?.popViewController(animated: true)
                            }
                            pushControllerImpl?(logoinVC)
                        }else{
                            pushControllerImpl?(biluAccountVC)
                        }
                    })
    })
    
    changeProfilePhotoImpl = {
        let _ = (contextValue.get()
        |> deliverOnMainQueue
        |> take(1)).start(next: { context in
            let _ = (context.account.postbox.transaction { transaction -> (Peer?, SearchBotsConfiguration) in
                return (transaction.getPeer(context.account.peerId), currentSearchBotsConfiguration(transaction: transaction))
            }
            |> deliverOnMainQueue).start(next: { peer, searchBotsConfiguration in
                let presentationData = context.sharedContext.currentPresentationData.with { $0 }
                
                let legacyController = LegacyController(presentation: .custom, theme: presentationData.theme)
                legacyController.statusBar.statusBarStyle = .Ignore
                
                let emptyController = LegacyEmptyController(context: legacyController.context)!
                let navigationController = makeLegacyNavigationController(rootController: emptyController)
                navigationController.setNavigationBarHidden(true, animated: false)
                navigationController.navigationBar.transform = CGAffineTransform(translationX: -1000.0, y: 0.0)
                
                legacyController.bind(controller: navigationController)
                
                presentControllerImpl?(legacyController, nil)
                
                var hasPhotos = false
                if let peer = peer, !peer.profileImageRepresentations.isEmpty {
                    hasPhotos = true
                }
                
                let completedImpl: (UIImage) -> Void = { image in
                    if let data = image.jpegData(compressionQuality: 0.6) {
                        let resource = LocalFileMediaResource(fileId: arc4random64())
                        context.account.postbox.mediaBox.storeResourceData(resource.id, data: data)
                        let representation = TelegramMediaImageRepresentation(dimensions: PixelDimensions(width: 640, height: 640), resource: resource)
                        updateState { state in
                            var state = state
                            state.updatingAvatar = .image(representation, true)
                            return state
                        }
                        updateAvatarDisposable.set((updateAccountPhoto(account: context.account, resource: resource, mapResourceToAvatarSizes: { resource, representations in
                            return mapResourceToAvatarSizes(postbox: context.account.postbox, resource: resource, representations: representations)
                        }) |> deliverOnMainQueue).start(next: { result in
                            switch result {
                            case .complete:
                                updateState { state in
                                    var state = state
                                    state.updatingAvatar = nil
                                    return state
                                }
                            case .progress:
                                break
                            }
                        }))
                    }
                }
                
                let mixin = TGMediaAvatarMenuMixin(context: legacyController.context, parentController: emptyController, hasSearchButton: true, hasDeleteButton: hasPhotos, hasViewButton: false, personalPhoto: true, saveEditedPhotos: false, saveCapturedMedia: false, signup: false)!
                let _ = currentAvatarMixin.swap(mixin)
                mixin.requestSearchController = { assetsController in
                    let controller = WebSearchController(context: context, peer: peer, configuration: searchBotsConfiguration, mode: .avatar(initialQuery: nil, completion: { result in
                        assetsController?.dismiss()
                        completedImpl(result)
                    }))
                    presentControllerImpl?(controller, ViewControllerPresentationArguments(presentationAnimation: .modalSheet))
                }
                mixin.didFinishWithImage = { image in
                    if let image = image {
                       completedImpl(image)
                    }
                }
                mixin.didFinishWithDelete = {
                    let _ = currentAvatarMixin.swap(nil)
                    updateState { state in
                        var state = state
                        if let profileImage = peer?.smallProfileImage {
                            state.updatingAvatar = .image(profileImage, false)
                        } else {
                            state.updatingAvatar = .none
                        }
                        return state
                    }
                    updateAvatarDisposable.set((updateAccountPhoto(account: context.account, resource: nil, mapResourceToAvatarSizes: { resource, representations in
                        return mapResourceToAvatarSizes(postbox: context.account.postbox, resource: resource, representations: representations)
                    }) |> deliverOnMainQueue).start(next: { result in
                        switch result {
                        case .complete:
                            updateState { state in
                                var state = state
                                state.updatingAvatar = nil
                                return state
                            }
                        case .progress:
                            break
                        }
                    }))
                }
                mixin.didDismiss = { [weak legacyController] in
                    let _ = currentAvatarMixin.swap(nil)
                    legacyController?.dismiss()
                }
                let menuController = mixin.present()
                if let menuController = menuController {
                    menuController.customRemoveFromParentViewController = { [weak legacyController] in
                        legacyController?.dismiss()
                    }
                }
            })
        })
    }
    
    let peerView = contextValue.get()
    |> mapToSignal { context -> Signal<PeerView, NoError> in
        return context.account.viewTracker.peerView(context.account.peerId, updateData: true)
    }
    
    archivedPacks.set(
        .single(nil)
        |> then(
            contextValue.get()
            |> mapToSignal { context -> Signal<[ArchivedStickerPackItem]?, NoError> in
                archivedStickerPacks(account: context.account)
                |> map(Optional.init)
            }
        )
    )
    
    #if ENABLE_WALLET
    let hasWallet = contextValue.get()
    |> mapToSignal { context in
        return context.hasWalletAccess
    }
    #else
    let hasWallet: Signal<Bool, NoError> = .single(false)
    #endif
    
    let hasPassport = ValuePromise<Bool>(false)
    let updatePassport: () -> Void = {
        updatePassportDisposable.set((
        contextValue.get()
        |> take(1)
        |> mapToSignal { context -> Signal<Bool, NoError> in
            return twoStepAuthData(context.account.network)
            |> map { value -> Bool in
                return value.hasSecretValues
            }
            |> `catch` { _ -> Signal<Bool, NoError> in
                return .single(false)
            }
        }
        |> deliverOnMainQueue).start(next: { value in
            hasPassport.set(value)
        }))
    }
    updatePassport()
    
    let updateActiveSessions: () -> Void = {
        let _ = (activeSessionsContextAndCount.get()
        |> deliverOnMainQueue
        |> take(1)).start(next: { activeSessionsContext, _, _ in
            activeSessionsContext.loadMore()
        })
    }
    
    let notificationsAuthorizationStatus = Promise<AccessType>(.allowed)
    if #available(iOSApplicationExtension 10.0, iOS 10.0, *) {
        notificationsAuthorizationStatus.set(
            .single(.allowed)
            |> then(
                contextValue.get()
                |> mapToSignal { context -> Signal<AccessType, NoError> in
                    return DeviceAccess.authorizationStatus(applicationInForeground: context.sharedContext.applicationBindings.applicationInForeground, subject: .notifications)
                }
            )
        )
    }
    
    let notificationsWarningSuppressed = Promise<Bool>(true)
    if #available(iOSApplicationExtension 10.0, iOS 10.0, *) {
        notificationsWarningSuppressed.set(
            .single(true)
            |> then(
                contextValue.get()
                |> mapToSignal { context -> Signal<Bool, NoError> in
                    return context.sharedContext.accountManager.noticeEntry(key: ApplicationSpecificNotice.permissionWarningKey(permission: .notifications)!)
                    |> map { noticeView -> Bool in
                        let timestamp = noticeView.value.flatMap({ ApplicationSpecificNotice.getTimestampValue($0) })
                        if let timestamp = timestamp, timestamp > 0 {
                            return true
                        } else {
                            return false
                        }
                    }
                }
            )
        )
    }
    
    let notifyExceptions = Promise<NotificationExceptionsList?>(NotificationExceptionsList(peers: [:], settings: [:]))
    let updateNotifyExceptions: () -> Void = {
        notifyExceptions.set(
            contextValue.get()
            |> take(1)
            |> mapToSignal { context -> Signal<NotificationExceptionsList?, NoError> in
                return .single(NotificationExceptionsList(peers: [:], settings: [:]))
                |> then(
                    notificationExceptionsList(postbox: context.account.postbox, network: context.account.network)
                    |> map(Optional.init)
                )
            }
        )
    }
    
    privacySettings.set(
    .single(nil)
    |> then(
        contextValue.get()
        |> mapToSignal { context -> Signal<AccountPrivacySettings?, NoError> in
            requestAccountPrivacySettings(account: context.account)
            |> map(Optional.init)
            }
        )
    )
    
    let hasWatchApp = contextValue.get()
    |> mapToSignal { context -> Signal<Bool, NoError> in
        if let watchManager = context.watchManager {
            return watchManager.watchAppInstalled
        } else {
            return .single(false)
        }
    }
    
    let updatedPresentationData = contextValue.get()
    |> mapToSignal { context -> Signal<PresentationData, NoError> in
        return context.sharedContext.presentationData
    }
    
    let preferences = context.sharedContext.accountManager.sharedData(keys: [SharedDataKeys.proxySettings, ApplicationSpecificSharedDataKeys.inAppNotificationSettings])
    
    let featuredStickerPacks = contextValue.get()
    |> mapToSignal { context in
        return context.account.viewTracker.featuredStickerPacks()
    }

    let enableQRLoginSignal = contextValue.get()
    |> mapToSignal { context -> Signal<Bool, NoError> in
        return context.account.postbox.preferencesView(keys: [PreferencesKeys.appConfiguration])
        |> map { view -> Bool in
            guard let appConfiguration = view.values[PreferencesKeys.appConfiguration] as? AppConfiguration else {
                return false
            }
            guard let data = appConfiguration.data, let enableQR = data["qr_login_camera"] as? Bool, enableQR else {
                return false
            }
            return true
        }
        |> distinctUntilChanged
    }
    enableQRLogin.set(enableQRLoginSignal)
    
    let enableFiltersSignal = contextValue.get()
    |> mapToSignal { context -> Signal<Bool, NoError> in
        return context.account.postbox.preferencesView(keys: [PreferencesKeys.appConfiguration])
        |> map { view -> Bool in
            guard let appConfiguration = view.values[PreferencesKeys.appConfiguration] as? AppConfiguration else {
                return false
            }
            let configuration = ChatListFilteringConfiguration(appConfiguration: appConfiguration)
            return configuration.isEnabled
        }
        |> distinctUntilChanged
    }
    enableFilters.set(enableFiltersSignal)

    let signal = combineLatest(queue: Queue.mainQueue(), contextValue.get(), updatedPresentationData, statePromise.get(), peerView, combineLatest(queue: Queue.mainQueue(), preferences, notifyExceptions.get(), notificationsAuthorizationStatus.get(), notificationsWarningSuppressed.get(), privacySettings.get(), displayPhoneNumberConfirmation.get()), combineLatest(featuredStickerPacks, archivedPacks.get()), combineLatest(hasWallet, hasPassport.get(), hasWatchApp, enableQRLogin.get(), enableFilters.get()), accountsAndPeers.get(), activeSessionsContextAndCount.get())
    |> map { context, presentationData, state, view, preferencesAndExceptions, featuredAndArchived, hasWalletPassportAndWatch, accountsAndPeers, activeSessionsContextAndCount -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let otherSessionCount = activeSessionsContextAndCount.1

        let proxySettings: ProxySettings = preferencesAndExceptions.0.entries[SharedDataKeys.proxySettings] as? ProxySettings ?? ProxySettings.defaultSettings
        let inAppNotificationSettings: InAppNotificationSettings = preferencesAndExceptions.0.entries[ApplicationSpecificSharedDataKeys.inAppNotificationSettings] as? InAppNotificationSettings ?? InAppNotificationSettings.defaultSettings
        let experimentalUISettings: ExperimentalUISettings = preferencesAndExceptions.0.entries[ApplicationSpecificSharedDataKeys.experimentalUISettings] as? ExperimentalUISettings ?? ExperimentalUISettings.defaultSettings
    
        let rightNavigationButton = ItemListNavigationButton(content: .text(presentationData.strings.Common_Edit), style: .regular, enabled: true, action: {
            arguments.openEditing()
        })
        
        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text(HLLanguage.TabBar.Mine.str), leftNavigationButton: nil, rightNavigationButton: rightNavigationButton, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
        
        var unreadTrendingStickerPacks = 0
        for item in featuredAndArchived.0 {
            if item.unread {
                unreadTrendingStickerPacks += 1
            }
        }
        
        let (hasWallet, hasPassport, hasWatchApp, enableQRLogin, enableFilters) = hasWalletPassportAndWatch
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: settingsEntries(account: context.account, presentationData: presentationData, state: state, view: view, proxySettings: proxySettings, notifyExceptions: preferencesAndExceptions.1, notificationsAuthorizationStatus: preferencesAndExceptions.2, notificationsWarningSuppressed: preferencesAndExceptions.3, unreadTrendingStickerPacks: unreadTrendingStickerPacks, archivedPacks: featuredAndArchived.1, privacySettings: preferencesAndExceptions.4, hasWallet: hasWallet, hasPassport: hasPassport, hasWatchApp: hasWatchApp, accountsAndPeers: accountsAndPeers.1, inAppNotificationSettings: inAppNotificationSettings, experimentalUISettings: experimentalUISettings, displayPhoneNumberConfirmation: preferencesAndExceptions.5, otherSessionCount: otherSessionCount, enableQRLogin: enableQRLogin, enableFilters: enableFilters), style: .blocks, searchItem: nil, initialScrollToItem: ListViewScrollToItem(index: 0, position: .top(-navigationBarSearchContentHeight), animated: false, curve: .Default(duration: 0.0), directionHint: .Up))
        
        return (controllerState, (listState, arguments))
    }
    |> afterDisposed {
        actionsDisposable.dispose()
    }
    
    let icon = UIImage(bundleImageName: "Chat List/Tabs/IconSettings")
    
    let notificationsFromAllAccounts = accountManager.sharedData(keys: [ApplicationSpecificSharedDataKeys.inAppNotificationSettings])
    |> map { sharedData -> Bool in
        let settings = sharedData.entries[ApplicationSpecificSharedDataKeys.inAppNotificationSettings] as? InAppNotificationSettings ?? InAppNotificationSettings.defaultSettings
        return settings.displayNotificationsFromAllAccounts
    }
    |> distinctUntilChanged
    
    let accountTabBarAvatarBadge: Signal<Int32, NoError> = combineLatest(notificationsFromAllAccounts, accountsAndPeers.get())
    |> map { notificationsFromAllAccounts, primaryAndOther -> Int32 in
        if !notificationsFromAllAccounts {
            return 0
        }
        let (primary, other) = primaryAndOther
        if let _ = primary, !other.isEmpty {
            return other.reduce(into: 0, { (result, next) in
                result += next.2
            })
        } else {
            return 0
        }
    }
    |> distinctUntilChanged
    
    let accountTabBarAvatar: Signal<(UIImage, UIImage)?, NoError> = combineLatest(accountsAndPeers.get(), updatedPresentationData)
    |> map { primaryAndOther, presentationData -> (Account, Peer, PresentationTheme)? in
        if let primary = primaryAndOther.0, !primaryAndOther.1.isEmpty {
            return (primary.0, primary.1, presentationData.theme)
        } else {
            return nil
        }
    }
    |> distinctUntilChanged(isEqual: { $0?.0 === $1?.0 && arePeersEqual($0?.1, $1?.1) && $0?.2 === $1?.2 })
    |> mapToSignal { primary -> Signal<(UIImage, UIImage)?, NoError> in
        if let primary = primary {
            let size = CGSize(width: 31.0, height: 31.0)
            let inset: CGFloat = 3.0
            if let signal = peerAvatarImage(account: primary.0, peerReference: PeerReference(primary.1), authorOfMessage: nil, representation: primary.1.profileImageRepresentations.first, displayDimensions: size, inset: 3.0, emptyColor: nil, synchronousLoad: false) {
                return signal
                |> map { imageVersions -> (UIImage, UIImage)? in
                    let image = imageVersions?.0
                    if let image = image, let selectedImage = generateImage(size, rotatedContext: { size, context in
                        context.clear(CGRect(origin: CGPoint(), size: size))
                        context.translateBy(x: size.width / 2.0, y: size.height / 2.0)
                        context.scaleBy(x: 1.0, y: -1.0)
                        context.translateBy(x: -size.width / 2.0, y: -size.height / 2.0)
                        context.draw(image.cgImage!, in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
                        context.setLineWidth(1.0)
                        context.setStrokeColor(primary.2.rootController.tabBar.selectedIconColor.cgColor)
                        context.strokeEllipse(in: CGRect(x: 1.5, y: 1.5, width: 28.0, height: 28.0))
                    }) {
                        return (image.withRenderingMode(.alwaysOriginal), selectedImage.withRenderingMode(.alwaysOriginal))
                    } else {
                        return nil
                    }
                }
            } else {
                return Signal { subscriber in
                    let image = generateImage(size, rotatedContext: { size, context in
                        context.clear(CGRect(origin: CGPoint(), size: size))
                        context.translateBy(x: inset, y: inset)
                        drawPeerAvatarLetters(context: context, size: CGSize(width: size.width - inset * 2.0, height: size.height - inset * 2.0), font: avatarFont, letters: primary.1.displayLetters, peerId: primary.1.id)
                    })?.withRenderingMode(.alwaysOriginal)
                    
                    let selectedImage = generateImage(size, rotatedContext: { size, context in
                        context.clear(CGRect(origin: CGPoint(), size: size))
                        context.translateBy(x: inset, y: inset)
                        drawPeerAvatarLetters(context: context, size: CGSize(width: size.width - inset * 2.0, height: size.height - inset * 2.0), font: avatarFont, letters: primary.1.displayLetters, peerId: primary.1.id)
                        context.translateBy(x: -inset, y: -inset)
                        context.setLineWidth(1.0)
                        context.setStrokeColor(primary.2.rootController.tabBar.selectedIconColor.cgColor)
                        context.strokeEllipse(in: CGRect(x: 1.0, y: 1.0, width: 27.0, height: 27.0))
                    })?.withRenderingMode(.alwaysOriginal)
                    
                    subscriber.putNext(image.flatMap { ($0, $0) })
                    subscriber.putCompletion()
                    return EmptyDisposable
                }
                |> runOn(.concurrentDefaultQueue())
            }
        } else {
            return .single(nil)
        }
    }
    |> distinctUntilChanged(isEqual: { lhs, rhs in
        if let lhs = lhs, let rhs = rhs {
            if lhs.0 !== rhs.0 || lhs.1 !== rhs.1 {
                return false
            } else {
                return true
            }
        } else if (lhs == nil) != (rhs == nil) {
            return false
        }
        return true
    })
    
    let tabBarItem: Signal<ItemListControllerTabBarItem, NoError> = combineLatest(queue: .mainQueue(), updatedPresentationData, notificationsAuthorizationStatus.get(), notificationsWarningSuppressed.get(), accountTabBarAvatar, accountTabBarAvatarBadge)
    |> map { presentationData, notificationsAuthorizationStatus, notificationsWarningSuppressed, accountTabBarAvatar, accountTabBarAvatarBadge -> ItemListControllerTabBarItem in
        let notificationsWarning = shouldDisplayNotificationsPermissionWarning(status: notificationsAuthorizationStatus, suppressed:  notificationsWarningSuppressed)
        var otherAccountsBadge: String?
        if accountTabBarAvatarBadge > 0 {
            otherAccountsBadge = compactNumericCountString(Int(accountTabBarAvatarBadge), decimalSeparator: presentationData.dateTimeFormat.decimalSeparator)
        }
        return ItemListControllerTabBarItem(title: HLLanguage.TabBar.Mine.str, image: accountTabBarAvatar?.0 ?? icon, selectedImage: accountTabBarAvatar?.1 ?? icon, tintImages: accountTabBarAvatar == nil, badgeValue: notificationsWarning ? "!" : otherAccountsBadge)
    }
    
    //MARK: 创建controller
    let controller = SettingsControllerImpl.init(currentContext: context, contextValue: contextValue, state: signal, tabBarItem: tabBarItem, accountsAndPeers: accountsAndPeers.get())
    
    pushControllerImpl = { [weak controller] value in
        (controller?.navigationController as? NavigationController)?.replaceAllButRootController(value, animated: true, animationOptions: [.removeOnMasterDetails])
    }
    presentControllerImpl = { [weak controller] value, arguments in
        controller?.present(value, in: .window(.root), with: arguments, blockInteraction: true)
    }
    presentInGlobalOverlayImpl = { [weak controller] value, arguments in
        controller?.presentInGlobalOverlay(value, with: arguments)
    }
    dismissInputImpl = { [weak controller] in
        controller?.view.window?.endEditing(true)
    }
    getNavigationControllerImpl = { [weak controller] in
        return (controller?.navigationController as? NavigationController)
    }
    avatarGalleryTransitionArguments = { [weak controller] entry in
        if let controller = controller {
            var result: ((ASDisplayNode, CGRect, () -> (UIView?, UIView?)), CGRect)?
            controller.forEachItemNode { itemNode in
                if let itemNode = itemNode as? ItemListAvatarAndNameInfoItemNode {
                    result = itemNode.avatarTransitionNode()
                }
            }
            if let (node, _) = result {
                return GalleryTransitionArguments(transitionNode: node, addToTransitionSurface: { _ in
                })
            }
        }
        return nil
    }
    updateHiddenAvatarImpl = { [weak controller] in
        if let controller = controller {
            controller.forEachItemNode { itemNode in
                if let itemNode = itemNode as? ItemListAvatarAndNameInfoItemNode {
                    itemNode.updateAvatarHidden()
                }
            }
        }
    }
    openSavedMessagesImpl = { [weak controller] in
        let _ = (contextValue.get()
        |> take(1)
        |> deliverOnMainQueue).start(next: { context in
            if let controller = controller, let navigationController = controller.navigationController as? NavigationController {
                context.sharedContext.navigateToChatController(NavigateToChatControllerParams(navigationController: navigationController, context: context, chatLocation: .peer(context.account.peerId)))
            }
        })
    }
    
    controller.tabBarItemDebugTapAction = {
        let _ = (contextValue.get()
        |> take(1)
        |> deliverOnMainQueue).start(next: { accountContext in
            pushControllerImpl?(debugController(sharedContext: accountContext.sharedContext, context: accountContext))
        })
    }
    
    displayCopyContextMenuImpl = { [weak controller] peer in
        let _ = (contextValue.get()
        |> take(1)
        |> deliverOnMainQueue).start(next: { context in
            if let strongController = controller {
                let presentationData = context.sharedContext.currentPresentationData.with { $0 }
                var resultItemNode: ListViewItemNode?
                let _ = strongController.frameForItemNode({ itemNode in
                    if let itemNode = itemNode as? ItemListAvatarAndNameInfoItemNode {
                        resultItemNode = itemNode
                        return true
                    }
                    return false
                })
                if let resultItemNode = resultItemNode, let user = peer as? TelegramUser {
                    var actions: [ContextMenuAction] = []
                    
                    if let phone = user.phone, !phone.isEmpty {
                        actions.append(ContextMenuAction(content: .text(title: presentationData.strings.Settings_CopyPhoneNumber, accessibilityLabel: presentationData.strings.Settings_CopyPhoneNumber), action: {
                            UIPasteboard.general.string = formatPhoneNumber(phone)
                        }))
                    }
                    
                    if let username = user.username, !username.isEmpty {
                        actions.append(ContextMenuAction(content: .text(title: presentationData.strings.Settings_CopyUsername, accessibilityLabel: presentationData.strings.Settings_CopyUsername), action: {
                            UIPasteboard.general.string = username
                        }))
                    }
                    
                    let contextMenuController = ContextMenuController(actions: actions)
                    strongController.present(contextMenuController, in: .window(.root), with: ContextMenuControllerPresentationArguments(sourceNodeAndRect: { [weak resultItemNode] in
                        if let strongController = controller, let resultItemNode = resultItemNode {
                            return (resultItemNode, resultItemNode.contentBounds.insetBy(dx: 0.0, dy: -2.0), strongController.displayNode, strongController.view.bounds)
                        } else {
                            return nil
                        }
                    }))
                }
            }
        })
    }
    
    removeAccountImpl = { id in
        let _ = (contextValue.get()
        |> deliverOnMainQueue
        |> take(1)).start(next: { context in
            let presentationData = context.sharedContext.currentPresentationData.with { $0 }
            let controller = ActionSheetController(presentationData: presentationData)
            let dismissAction: () -> Void = { [weak controller] in
                controller?.dismissAnimated()
            }
            
            var items: [ActionSheetItem] = []
            items.append(ActionSheetTextItem(title: presentationData.strings.Settings_LogoutConfirmationText.trimmingCharacters(in: .whitespacesAndNewlines)))
            items.append(ActionSheetButtonItem(title: presentationData.strings.Settings_Logout, color: .destructive, action: {
                dismissAction()
                let _ = logoutFromAccount(id: id, accountManager: context.sharedContext.accountManager, alreadyLoggedOutRemotely: false).start()
            }))
            controller.setItemGroups([
                ActionSheetItemGroup(items: items),
                ActionSheetItemGroup(items: [ActionSheetButtonItem(title: presentationData.strings.Common_Cancel, action: { dismissAction() })])
                ])
            presentControllerImpl?(controller, ViewControllerPresentationArguments(presentationAnimation: .modalSheet))
        })
    }
    
    switchToAccountImpl = { id in
        let _ = (contextValue.get()
        |> take(1)
        |> deliverOnMainQueue).start(next: { context in
            //清除token
            HLAccountManager.cleanWalletToken()
            
            accountsAndPeers.set(.never())
            context.sharedContext.switchToAccount(id: id, fromSettingsController: nil, withChatListController: nil)
        })
    }
    
    controller.didAppear = { _ in
        updatePassport()
        updateNotifyExceptions()
        updateActiveSessions()
    }
    
    controller.previewItemWithTag = { tag in
        if let tag = tag as? SettingsEntryTag, case let .account(id) = tag {
            var selectedAccount: Account?
            let _ = (accountsAndPeers.get()
            |> take(1)
            |> deliverOnMainQueue).start(next: { accountsAndPeers in
                for (account, _, _) in accountsAndPeers.1 {
                    if account.id == id {
                        selectedAccount = account
                        break
                    }
                }
            })
            var sharedContext: SharedAccountContext?
            let _ = (contextValue.get()
            |> deliverOnMainQueue
            |> take(1)).start(next: { context in
                sharedContext = context.sharedContext
            })
            if let selectedAccount = selectedAccount, let sharedContext = sharedContext {
                let accountContext = sharedContext.makeTempAccountContext(account: selectedAccount)
                let chatListController = accountContext.sharedContext.makeChatListController(context: accountContext, groupId: .root, controlsHistoryPreload: false, hideNetworkActivityStatus: true, previewing: true, enableDebugActions: enableDebugActions)
                return chatListController
            }
        }
        return nil
    }
    
    controller.commitPreview = { previewController in
        if let chatListController = previewController as? ChatListController {
            let _ = (contextValue.get()
            |> deliverOnMainQueue
            |> take(1)).start(next: { context in
                context.sharedContext.switchToAccount(id: chatListController.context.account.id, fromSettingsController: nil, withChatListController: chatListController)
            })
        }
    }
    
    controller.switchToAccount = { id in
        let _ = (contextValue.get()
        |> take(1)
        |> deliverOnMainQueue).start(next: { context in
            context.sharedContext.switchToAccount(id: id, fromSettingsController: nil, withChatListController: nil)
        })
    }
    
    controller.addAccount = {
        let _ = (contextValue.get()
        |> take(1)
        |> deliverOnMainQueue).start(next: { context in
            context.sharedContext.beginNewAuth(testingEnvironment: false)
        })
    }
    
    controller.contentOffsetChanged = { [weak controller] offset, inVoiceOver in
        if let controller = controller, let navigationBar = controller.navigationBar, let searchContentNode = navigationBar.contentNode as? NavigationBarSearchContentNode {
            var offset = offset
            if inVoiceOver {
                offset = .known(0.0)
            }
            searchContentNode.updateListVisibleContentOffset(offset)
        }
    }
    
    controller.contentScrollingEnded = { [weak controller] listNode in
        if let controller = controller, let navigationBar = controller.navigationBar, let searchContentNode = navigationBar.contentNode as? NavigationBarSearchContentNode {
            return fixNavigationSearchableListNodeScrolling(listNode, searchNode: searchContentNode)
        }
        return false
    }
    
    controller.willScrollToTop = { [weak controller] in
         if let controller = controller, let navigationBar = controller.navigationBar, let searchContentNode = navigationBar.contentNode as? NavigationBarSearchContentNode {
            searchContentNode.updateExpansionProgress(1.0, animated: true)
        }
    }
    
    controller.didDisappear = { [weak controller] _ in
        controller?.clearItemNodesHighlight(animated: true)
        setDisplayNavigationBarImpl?(true)
        updateState { state in
            var state = state
            state.isSearching = false
            return state
        }
    }
    //MARK: -WillAppear
    let kShowWalletGuideKey = "kShowWalletGuideKey"
    controller.willAppear = {[weak controller]  _ in
        
        guard let controller = controller,
            HLAccountManager.walletIsLogined else {return}
        repo.unreadNotice().value { data in
            debugPrint(data)
            updateState { state in
                var state = state
                state.unread = data.unread
                controller.tabBarItem.badgeValue = state.unread ? "0" : ""
                return state
            }
        }.load(controller.disposeBag)
        if UserDefaults.standard.bool(forKey: kShowWalletGuideKey) == true {return}
        let itemFrame = CGRect(x: 0, y: 130 + NavBarHeight , width: kScreenWidth, height: 44 )
            GuideView.show(mold: GuideView.Mold.wallet, target: itemFrame)
            UserDefaults.standard.set(true, forKey:kShowWalletGuideKey)
    }

    setDisplayNavigationBarImpl = { [weak controller] display in
        controller?.setDisplayNavigationBar(display, transition: .animated(duration: 0.5, curve: .spring))
    }
    
    return controller
}

//private func accountContextMenuItems(context: AccountContext, logout: @escaping () -> Void) -> Signal<[ContextMenuItem], NoError> {
//    let strings = context.sharedContext.currentPresentationData.with({ $0 }).strings
//    return context.account.postbox.transaction { transaction -> [ContextMenuItem] in
//        var items: [ContextMenuItem] = []
//
//        if !transaction.getUnreadChatListPeerIds(groupId: .root, filterPredicate: nil).isEmpty {
//            items.append(.action(ContextMenuActionItem(text: strings.ChatList_Context_MarkAllAsRead, icon: { theme in generateTintedImage(image: UIImage(bundleImageName: "Chat/Context Menu/MarkAsRead"), color: theme.contextMenu.primaryColor) }, action: { _, f in
//                let _ = (context.account.postbox.transaction { transaction in
//                    markAllChatsAsReadInteractively(transaction: transaction, viewTracker: context.account.viewTracker, groupId: .root, filterPredicate: nil)
//                }
//                |> deliverOnMainQueue).start(completed: {
//                    f(.default)
//                })
//            })))
//        }
//
//        items.append(.action(ContextMenuActionItem(text: strings.Settings_Context_Logout, textColor: .destructive, icon: { theme in generateTintedImage(image: UIImage(bundleImageName: "Chat/Context Menu/Logout"), color: theme.contextMenu.destructiveColor) }, action: { _, f in
//            logout()
//            f(.default)
//        })))
//
//        return items
//    }
//}
