import Foundation
import UIKit
import Display
import AsyncDisplayKit
import Postbox
import TelegramCore
import SyncCore
import SwiftSignalKit
import TelegramPresentationData
import AccountContext
import ContactListUI
import CallListUI
import ChatListUI
import SettingsUI
import AppBundle
import DeviceAccess
import TelegramPermissionsUI
import TelegramPermissions

public final class TelegramRootController: NavigationController {
    private let context: AccountContext
    
    public var rootTabController: TabBarController?
    
    public var contactsController: ContactsController?
    public var callListController: CallListController?
    public var chatListController: ChatListController?
    var discoverController: NewDiscoverVC?
    public var accountSettingsController: ViewController?
    
    private var permissionsDisposable: Disposable?
    private var presentationDataDisposable: Disposable?
    private var presentationData: PresentationData
        
    public init(context: AccountContext) {
        self.context = context
        
        self.presentationData = context.sharedContext.currentPresentationData.with { $0 }
        
        let navigationDetailsBackgroundMode: NavigationEmptyDetailsBackgoundMode?
        switch presentationData.chatWallpaper {
        case .color:
            let image = generateTintedImage(image: UIImage(bundleImageName: "Chat List/EmptyMasterDetailIcon"), color: presentationData.theme.chatList.messageTextColor.withAlphaComponent(0.2))
            navigationDetailsBackgroundMode = image != nil ? .image(image!) : nil
        default:
            let image = chatControllerBackgroundImage(theme: presentationData.theme, wallpaper: presentationData.chatWallpaper, mediaBox: context.account.postbox.mediaBox, knockoutMode: context.sharedContext.immediateExperimentalUISettings.knockoutWallpaper)
            navigationDetailsBackgroundMode = image != nil ? .wallpaper(image!) : nil
        }
        
        super.init(mode: .automaticMasterDetail, theme: NavigationControllerTheme(presentationTheme: self.presentationData.theme), backgroundDetailsMode: navigationDetailsBackgroundMode)
        
        self.presentationDataDisposable = (context.sharedContext.presentationData
        |> deliverOnMainQueue).start(next: { [weak self] presentationData in
            if let strongSelf = self {
                if presentationData.chatWallpaper != strongSelf.presentationData.chatWallpaper {
                    let navigationDetailsBackgroundMode: NavigationEmptyDetailsBackgoundMode?
                    switch presentationData.chatWallpaper {
                        case .color:
                            let image = generateTintedImage(image: UIImage(bundleImageName: "Chat List/EmptyMasterDetailIcon"), color: presentationData.theme.chatList.messageTextColor.withAlphaComponent(0.2))
                            navigationDetailsBackgroundMode = image != nil ? .image(image!) : nil
                        default:
                            navigationDetailsBackgroundMode = chatControllerBackgroundImage(theme: presentationData.theme, wallpaper: presentationData.chatWallpaper, mediaBox: strongSelf.context.sharedContext.accountManager.mediaBox, knockoutMode: strongSelf.context.sharedContext.immediateExperimentalUISettings.knockoutWallpaper).flatMap(NavigationEmptyDetailsBackgoundMode.wallpaper)
                    }
                    strongSelf.updateBackgroundDetailsMode(navigationDetailsBackgroundMode, transition: .immediate)
                }

                let previousTheme = strongSelf.presentationData.theme
                strongSelf.presentationData = presentationData
                if previousTheme !== presentationData.theme {
                    strongSelf.rootTabController?.updateTheme(navigationBarPresentationData: NavigationBarPresentationData(presentationData: presentationData), theme: TabBarControllerTheme(rootControllerTheme: presentationData.theme))
                    strongSelf.rootTabController?.statusBar.statusBarStyle = presentationData.theme.rootController.statusBarStyle.style
                }
            }
        })
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.permissionsDisposable?.dispose()
        self.presentationDataDisposable?.dispose()
    }
    
    public func addRootControllers(showCallsTab: Bool) {
        let tabBarController = TabBarController(navigationBarPresentationData: NavigationBarPresentationData(presentationData: self.presentationData), theme: TabBarControllerTheme(rootControllerTheme: self.presentationData.theme))
        tabBarController.navigationPresentation = .master
        let chatListController = self.context.sharedContext.makeChatListController(context: self.context, groupId: .root, controlsHistoryPreload: true, hideNetworkActivityStatus: false, previewing: false, enableDebugActions: !GlobalExperimentalSettings.isAppStoreBuild)
        if let sharedContext = self.context.sharedContext as? SharedAccountContextImpl {
            chatListController.tabBarItem.badgeValue = sharedContext.switchingData.chatListBadge
        }
        let callListController = CallListController(context: self.context, mode: .tab)
        
        let contactsController = ContactsController(context: self.context)
        contactsController.switchToChatsController = {  [weak self] in
            self?.openChatsController(activateSearch: false)
        }
        //打开群组/频道
        contactsController.openGroupAndChannel = { [weak contactsController, weak self] in
            guard let vc = contactsController, let self = self else { return }
            let chatListController = ContactViewController(context: self.context, groupId: .root, controlsHistoryPreload: true,presentationData: (self.context.sharedContext.currentPresentationData.with { $0 }))
             (vc.navigationController as? NavigationController)?.pushViewController(chatListController, completion: {
             })
        }
        //跳转到附近的人
        contactsController.openNearby = { [weak contactsController, weak self] in
            guard let vc = contactsController, let self = self else { return }
            self.pushNearbyVC(nav: (vc.navigationController as? NavigationController), context: self.context, presentationData: (self.context.sharedContext.currentPresentationData.with { $0 }))
        }
        
        var restoreSettignsController: (ViewController & SettingsController)?
        if let sharedContext = self.context.sharedContext as? SharedAccountContextImpl {
            restoreSettignsController = sharedContext.switchingData.settingsController
        }
        restoreSettignsController?.updateContext(context: self.context)
        if let sharedContext = self.context.sharedContext as? SharedAccountContextImpl {
            sharedContext.switchingData = (nil, nil, nil)
        }
        
        let accountSettingsController = restoreSettignsController ?? hlSettingsController(context: self.context, accountManager: context.sharedContext.accountManager, enableDebugActions: !GlobalExperimentalSettings.isAppStoreBuild)
        
        let discoverVC = NewDiscoverVC(context: self.context)
        
        let viewControllers = [chatListController,contactsController,discoverVC,accountSettingsController]
        
        //下标
        let chatListIndex = viewControllers.firstIndex(of: chatListController)
        let settingIndex = viewControllers.firstIndex(of: accountSettingsController)
        
        tabBarController.setControllers(viewControllers, selectedIndex: restoreSettignsController != nil ? settingIndex : chatListIndex)
        
        self.contactsController = contactsController
        self.callListController = callListController
        self.chatListController = chatListController
        self.discoverController = discoverVC
        self.accountSettingsController = accountSettingsController
        self.rootTabController = tabBarController
        self.pushViewController(tabBarController, animated: false)
    }
        
    public func updateRootControllers(showCallsTab: Bool) {
        guard let rootTabController = self.rootTabController else {
            return
        }
       
        var controllers: [ViewController] = []
        //调整顺序
        controllers.append(self.chatListController!)
        controllers.append(self.contactsController!)
        //隐藏通话列表页面
        //        if showCallsTab {
        //            controllers.append(self.callListController!)
        //        }
        controllers.append(self.discoverController!)
        controllers.append(self.accountSettingsController!)
        
        rootTabController.setControllers(controllers, selectedIndex: nil)
    }
    
    public func openChatsController(activateSearch: Bool) {
        guard let rootTabController = self.rootTabController else {
            return
        }
        
        if activateSearch {
            self.popToRoot(animated: false)
        }
        
        if let index = rootTabController.controllers.firstIndex(where: { $0 is ChatListController}) {
            rootTabController.selectedIndex = index
        }
        
        if activateSearch {
            self.chatListController?.activateSearch()
        }
    }
    
    public func openRootCompose() {
        self.chatListController?.activateCompose()
    }
    
    public func openRootCamera() {
        guard let controller = self.viewControllers.last as? ViewController else {
            return
        }
        controller.view.endEditing(true)
        presentedLegacyShortcutCamera(context: self.context, saveCapturedMedia: false, saveEditedPhotos: false, mediaGrouping: true, parentController: controller)
    }
    
    
    public func pushNearbyVC(nav: NavigationController?, context: AccountContext?, presentationData: PresentationData?) {
        guard let context = context else { return }
        let _ = (DeviceAccess.authorizationStatus(subject: .location(.tracking))
        |> take(1)
        |> deliverOnMainQueue).start(next: { [weak self] status in
            
            let presentPeersNearby = {
                let controller = NearbyViewController.init(context: context, presentationData: presentationData)

                nav?.replaceAllButRootController(controller, animated: true, completion: {})
            }
            
            switch status {
                case .allowed:
                    presentPeersNearby()
                default:
                    let controller = PermissionController(context: context, splashScreen: false)
                    controller.setState(.permission(.nearbyLocation(status: PermissionRequestStatus(accessType: status))), animated: false)
                    controller.proceed = { result in
                        if result {
                            presentPeersNearby()
                        } else {
                            let _ = nav?.popViewController(animated: true)
                        }
                    }
                    nav?.pushViewController(controller, completion: { })
            }
        })
    }
}
