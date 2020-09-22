import Foundation
import SwiftSignalKit
import UIKit
import Postbox
import TelegramCore
import SyncCore
import Display
import DeviceAccess
import TelegramPresentationData
import AccountContext
import LiveLocationManager
import TemporaryCachedPeerDataManager
#if ENABLE_WALLET
import WalletCore
import WalletUI
#endif
import PhoneNumberFormat
import TelegramUIPreferences
import TelegramVoip
import TelegramCallsUI

private final class DeviceSpecificContactImportContext {
    let disposable = MetaDisposable()
    var reference: DeviceContactBasicDataWithReference?
    
    init() {
    }
    
    deinit {
        self.disposable.dispose()
    }
}

private final class DeviceSpecificContactImportContexts {
    private let queue: Queue
    
    private var contexts: [PeerId: DeviceSpecificContactImportContext] = [:]
    
    init(queue: Queue) {
        self.queue = queue
    }
    
    deinit {
        assert(self.queue.isCurrent())
    }
    
    func update(account: Account, deviceContactDataManager: DeviceContactDataManager, references: [PeerId: DeviceContactBasicDataWithReference]) {
        var validIds = Set<PeerId>()
        for (peerId, reference) in references {
            validIds.insert(peerId)
            
            let context: DeviceSpecificContactImportContext
            if let current = self.contexts[peerId] {
                context = current
            } else {
                context = DeviceSpecificContactImportContext()
                self.contexts[peerId] = context
            }
            if context.reference != reference {
                context.reference = reference
                
                let key: PostboxViewKey = .basicPeer(peerId)
                let signal = account.postbox.combinedView(keys: [key])
                |> map { view -> String? in
                    if let user = (view.views[key] as? BasicPeerView)?.peer as? TelegramUser {
                        return user.phone
                    } else {
                        return nil
                    }
                }
                |> distinctUntilChanged
                |> mapToSignal { phone -> Signal<Never, NoError> in
                    guard let phone = phone else {
                        return .complete()
                    }
                    var found = false
                    let formattedPhone = formatPhoneNumber(phone)
                    for number in reference.basicData.phoneNumbers {
                        if formatPhoneNumber(number.value) == formattedPhone {
                            found = true
                            break
                        }
                    }
                    if !found {
                        return deviceContactDataManager.appendPhoneNumber(DeviceContactPhoneNumberData(label: "_$!<Mobile>!$_", value: formattedPhone), to: reference.stableId)
                        |> ignoreValues
                    } else {
                        return .complete()
                    }
                }
                context.disposable.set(signal.start())
            }
        }
        
        var removeIds: [PeerId] = []
        for peerId in self.contexts.keys {
            if !validIds.contains(peerId) {
                removeIds.append(peerId)
            }
        }
        for peerId in removeIds {
            self.contexts.removeValue(forKey: peerId)
        }
    }
}

public final class AccountContextImpl: AccountContext {
    public let sharedContextImpl: SharedAccountContextImpl
    public var sharedContext: SharedAccountContext {
        return self.sharedContextImpl
    }
    public let account: Account
    
    #if ENABLE_WALLET
    public let tonContext: StoredTonContext?
    #endif
    
    public let fetchManager: FetchManager
    private let prefetchManager: PrefetchManager?
    
    public var keyShortcutsController: KeyShortcutsController?
    
    public let downloadedMediaStoreManager: DownloadedMediaStoreManager
    
    public let liveLocationManager: LiveLocationManager?
    public let peersNearbyManager: PeersNearbyManager?
    public let wallpaperUploadManager: WallpaperUploadManager?
    private let themeUpdateManager: ThemeUpdateManager?
    
    public let peerChannelMemberCategoriesContextsManager = PeerChannelMemberCategoriesContextsManager()
    
    public let currentLimitsConfiguration: Atomic<LimitsConfiguration>
    private let _limitsConfiguration = Promise<LimitsConfiguration>()
    public var limitsConfiguration: Signal<LimitsConfiguration, NoError> {
        return self._limitsConfiguration.get()
    }
    
    public var currentContentSettings: Atomic<ContentSettings>
    private let _contentSettings = Promise<ContentSettings>()
    public var contentSettings: Signal<ContentSettings, NoError> {
        return self._contentSettings.get()
    }
    
    public var currentAppConfiguration: Atomic<AppConfiguration>
    private let _appConfiguration = Promise<AppConfiguration>()
    public var appConfiguration: Signal<AppConfiguration, NoError> {
        return self._appConfiguration.get()
    }
    
    public var watchManager: WatchManager?
    
    private var storedPassword: (String, CFAbsoluteTime, SwiftSignalKit.Timer)?
    private var limitsConfigurationDisposable: Disposable?
    private var contentSettingsDisposable: Disposable?
    private var appConfigurationDisposable: Disposable?
    
    private let deviceSpecificContactImportContexts: QueueLocalObject<DeviceSpecificContactImportContexts>
    private var managedAppSpecificContactsDisposable: Disposable?
    
    private var experimentalUISettingsDisposable: Disposable?
    
    #if ENABLE_WALLET
    public var hasWallets: Signal<Bool, NoError> {
        return WalletStorageInterfaceImpl(postbox: self.account.postbox).getWalletRecords()
        |> map { records in
            return !records.isEmpty
        }
    }
    
    public var hasWalletAccess: Signal<Bool, NoError> {
        return self.account.postbox.preferencesView(keys: [PreferencesKeys.appConfiguration])
        |> map { view -> Bool in
            guard let appConfiguration = view.values[PreferencesKeys.appConfiguration] as? AppConfiguration else {
                return false
            }
            let walletConfiguration = WalletConfiguration.with(appConfiguration: appConfiguration)
            if walletConfiguration.config != nil && walletConfiguration.blockchainName != nil {
                return true
            } else {
                return false
            }
        }
        |> distinctUntilChanged
    }
    #endif
    
    public init(sharedContext: SharedAccountContextImpl, account: Account, /*tonContext: StoredTonContext?, */limitsConfiguration: LimitsConfiguration, contentSettings: ContentSettings, appConfiguration: AppConfiguration, temp: Bool = false)
    {
        self.sharedContextImpl = sharedContext
        self.account = account
        #if ENABLE_WALLET
        self.tonContext = tonContext
        #endif
        
        self.downloadedMediaStoreManager = DownloadedMediaStoreManagerImpl(postbox: account.postbox, accountManager: sharedContext.accountManager)
        
        if let locationManager = self.sharedContextImpl.locationManager {
            self.liveLocationManager = LiveLocationManagerImpl(postbox: account.postbox, network: account.network, accountPeerId: account.peerId, viewTracker: account.viewTracker, stateManager: account.stateManager, locationManager: locationManager, inForeground: sharedContext.applicationBindings.applicationInForeground)
        } else {
            self.liveLocationManager = nil
        }
        self.fetchManager = FetchManagerImpl(postbox: account.postbox, storeManager: self.downloadedMediaStoreManager)
        if sharedContext.applicationBindings.isMainApp && !temp {
            self.prefetchManager = PrefetchManager(sharedContext: sharedContext, account: account, fetchManager: self.fetchManager)
            self.wallpaperUploadManager = WallpaperUploadManagerImpl(sharedContext: sharedContext, account: account, presentationData: sharedContext.presentationData)
            self.themeUpdateManager = ThemeUpdateManagerImpl(sharedContext: sharedContext, account: account)
        } else {
            self.prefetchManager = nil
            self.wallpaperUploadManager = nil
            self.themeUpdateManager = nil
        }
        
        if let locationManager = self.sharedContextImpl.locationManager, sharedContext.applicationBindings.isMainApp && !temp {
            self.peersNearbyManager = PeersNearbyManagerImpl(account: account, locationManager: locationManager, inForeground: sharedContext.applicationBindings.applicationInForeground)
        } else {
            self.peersNearbyManager = nil
        }
        
        let updatedLimitsConfiguration = account.postbox.preferencesView(keys: [PreferencesKeys.limitsConfiguration])
        |> map { preferences -> LimitsConfiguration in
            return preferences.values[PreferencesKeys.limitsConfiguration] as? LimitsConfiguration ?? LimitsConfiguration.defaultValue
        }
        
        self.currentLimitsConfiguration = Atomic(value: limitsConfiguration)
        self._limitsConfiguration.set(.single(limitsConfiguration) |> then(updatedLimitsConfiguration))
        
        let currentLimitsConfiguration = self.currentLimitsConfiguration
        self.limitsConfigurationDisposable = (self._limitsConfiguration.get()
        |> deliverOnMainQueue).start(next: { value in
            let _ = currentLimitsConfiguration.swap(value)
        })
        
        let updatedContentSettings = getContentSettings(postbox: account.postbox)
        self.currentContentSettings = Atomic(value: contentSettings)
        self._contentSettings.set(.single(contentSettings) |> then(updatedContentSettings))
        
        let currentContentSettings = self.currentContentSettings
        self.contentSettingsDisposable = (self._contentSettings.get()
        |> deliverOnMainQueue).start(next: { value in
            let _ = currentContentSettings.swap(value)
        })
        
        let updatedAppConfiguration = getAppConfiguration(postbox: account.postbox)
        self.currentAppConfiguration = Atomic(value: appConfiguration)
        self._appConfiguration.set(.single(appConfiguration) |> then(updatedAppConfiguration))
        
        let currentAppConfiguration = self.currentAppConfiguration
        self.appConfigurationDisposable = (self._appConfiguration.get()
        |> deliverOnMainQueue).start(next: { value in
            let _ = currentAppConfiguration.swap(value)
        })
        
        let queue = Queue()
        self.deviceSpecificContactImportContexts = QueueLocalObject(queue: queue, generate: {
            return DeviceSpecificContactImportContexts(queue: queue)
        })
        
        if let contactDataManager = sharedContext.contactDataManager {
            let deviceSpecificContactImportContexts = self.deviceSpecificContactImportContexts
            self.managedAppSpecificContactsDisposable = (contactDataManager.appSpecificReferences()
            |> deliverOn(queue)).start(next: { appSpecificReferences in
                deviceSpecificContactImportContexts.with { context in
                    context.update(account: account, deviceContactDataManager: contactDataManager, references: appSpecificReferences)
                }
            })
        }
        
        account.callSessionManager.updateVersions(versions: PresentationCallManagerImpl.voipVersions(includeExperimental: true, includeReference: false).map { version, supportsVideo -> CallSessionManagerImplementationVersion in
            CallSessionManagerImplementationVersion(version: version, supportsVideo: supportsVideo)
        })
    }
    
    deinit {
        self.limitsConfigurationDisposable?.dispose()
        self.managedAppSpecificContactsDisposable?.dispose()
        self.contentSettingsDisposable?.dispose()
        self.appConfigurationDisposable?.dispose()
        self.experimentalUISettingsDisposable?.dispose()
    }
    
    public func storeSecureIdPassword(password: String) {
        self.storedPassword?.2.invalidate()
        let timer = SwiftSignalKit.Timer(timeout: 1.0 * 60.0 * 60.0, repeat: false, completion: { [weak self] in
            self?.storedPassword = nil
        }, queue: Queue.mainQueue())
        self.storedPassword = (password, CFAbsoluteTimeGetCurrent(), timer)
        timer.start()
    }
    
    public func getStoredSecureIdPassword() -> String? {
        if let (password, timestamp, timer) = self.storedPassword {
            if CFAbsoluteTimeGetCurrent() > timestamp + 1.0 * 60.0 * 60.0 {
                timer.invalidate()
                self.storedPassword = nil
            }
            return password
        } else {
            return nil
        }
    }
    
    public func chatLocationInput(for location: ChatLocation, contextHolder: Atomic<ChatLocationContextHolder?>) -> ChatLocationInput {
        switch location {
        case let .peer(peerId):
            return .peer(peerId)
        case let .replyThread(data):
            let context = chatLocationContext(holder: contextHolder, account: self.account, data: data)
            return .external(data.messageId.peerId, context.state)
        }
    }
    
    public func chatLocationOutgoingReadState(for location: ChatLocation, contextHolder: Atomic<ChatLocationContextHolder?>) -> Signal<MessageId?, NoError> {
        switch location {
        case .peer:
            return .single(nil)
        case let .replyThread(data):
            let context = chatLocationContext(holder: contextHolder, account: self.account, data: data)
            return context.maxReadOutgoingMessageId
        }
    }
    
    public func applyMaxReadIndex(for location: ChatLocation, contextHolder: Atomic<ChatLocationContextHolder?>, messageIndex: MessageIndex) {
        switch location {
        case .peer:
            let _ = applyMaxReadIndexInteractively(postbox: self.account.postbox, stateManager: self.account.stateManager, index: messageIndex).start()
        case let .replyThread(data):
            let context = chatLocationContext(holder: contextHolder, account: self.account, data: data)
            context.applyMaxReadIndex(messageIndex: messageIndex)
        }
    }
}

private func chatLocationContext(holder: Atomic<ChatLocationContextHolder?>, account: Account, data: ChatReplyThreadMessage) -> ReplyThreadHistoryContext {
    let holder = holder.modify { current in
        if let current = current as? ChatLocationContextHolderImpl {
            return current
        } else {
            return ChatLocationContextHolderImpl(account: account, data: data)
        }
    } as! ChatLocationContextHolderImpl
    return holder.context
}

private final class ChatLocationContextHolderImpl: ChatLocationContextHolder {
    let context: ReplyThreadHistoryContext
    
    init(account: Account, data: ChatReplyThreadMessage) {
        self.context = ReplyThreadHistoryContext(account: account, peerId: data.messageId.peerId, data: data)
    }
}

func getAppConfiguration(transaction: Transaction) -> AppConfiguration {
    let appConfiguration: AppConfiguration = transaction.getPreferencesEntry(key: PreferencesKeys.appConfiguration) as? AppConfiguration ?? AppConfiguration.defaultValue
    return appConfiguration
}

func getAppConfiguration(postbox: Postbox) -> Signal<AppConfiguration, NoError> {
    return postbox.preferencesView(keys: [PreferencesKeys.appConfiguration])
    |> map { view -> AppConfiguration in
        let appConfiguration: AppConfiguration = view.values[PreferencesKeys.appConfiguration] as? AppConfiguration ?? AppConfiguration.defaultValue
        return appConfiguration
    }
    |> distinctUntilChanged
}
