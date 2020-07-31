import Foundation
import UIKit
import Display
import AsyncDisplayKit
import Postbox
import TelegramCore
import SyncCore
import SwiftSignalKit
import TelegramPresentationData
import LegacyComponents

import RMIntro

import Language
import Account

final class AuthorizationSequenceSplashController: ViewController {
    private var controllerNode: AuthorizationSequenceSplashControllerNode {
        return self.displayNode as! AuthorizationSequenceSplashControllerNode
    }
    
    private let accountManager: AccountManager
    private let postbox: Postbox
    private let network: Network
    private let theme: PresentationTheme
    
    private let controller: RMIntroViewController
    
    private var validLayout: ContainerViewLayout?
    
    var nextPressed: ((PresentationStrings?) -> Void)?
    
    private let suggestedLocalization = Promise<SuggestedLocalizationInfo?>()
    private let activateLocalizationDisposable = MetaDisposable()
    
    init(accountManager: AccountManager, postbox: Postbox, network: Network, theme: PresentationTheme) {
        self.accountManager = accountManager
        self.postbox = postbox
        self.network = network
        self.theme = theme
        
        self.suggestedLocalization.set(.single(nil)
            |> SwiftSignalKit.then(currentlySuggestedLocalization(network: network, extractKeys: ["Login.ContinueWithLocalization"])))
        let suggestedLocalization = self.suggestedLocalization
        
        let localizationSignal = SSignal(generator: { subscriber in
            let disposable = suggestedLocalization.get().start(next: { localization in
                guard let localization = localization else {
                    return
                }
                
                var continueWithLanguageString: String = "Continue"
                for entry in localization.extractedEntries {
                    switch entry {
                        case let .string(key, value):
                            if key == "Login.ContinueWithLocalization" {
                                continueWithLanguageString = value
                            }
                        default:
                            break
                    }
                }
                
                if let available = localization.availableLocalizations.first, available.languageCode != "en" {
                    let value = TGSuggestedLocalization(info: TGAvailableLocalization(title: available.title, localizedTitle: available.localizedTitle, code: available.languageCode), continueWithLanguageString: continueWithLanguageString, chooseLanguageString: "Choose Language", chooseLanguageOtherString: "Choose Language", englishLanguageNameString: "English")
                    subscriber?.putNext(value)
                }
            }, completed: {
                subscriber?.putCompletion()
            })
            
            return SBlockDisposable(block: {
                disposable.dispose()
            })
        })
        
        //MARK: --这是介绍页VC
        self.controller = RMIntroViewController(backgroundColor: theme.list.plainBackgroundColor, primaryColor: theme.list.itemPrimaryTextColor, buttonColor: theme.intro.startButtonColor, accentColor: theme.list.itemAccentColor, regularDotColor: theme.intro.dotColor, highlightedDotColor: theme.list.itemPrimaryTextColor, suggestedLocalizationSignal: localizationSignal)
        
        super.init(navigationBarPresentationData: nil)
        
        self.supportedOrientations = ViewControllerSupportedOrientations(regularSize: .all, compactSize: .portrait)
        
        self.statusBar.statusBarStyle = theme.intro.statusBarStyle.style
        //点击了确定按钮
        self.controller.startMessaging = { [weak self] in
            //self?.activateLocalization("en")
            self?.activateLocalization("zh-hans-raw")
        }
        self.controller.startMessagingInAlternativeLanguage = { [weak self] code in
            if let code = code {
                self?.activateLocalization(code)
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.activateLocalizationDisposable.dispose()
    }
    
    override public func loadDisplayNode() {
        self.displayNode = AuthorizationSequenceSplashControllerNode(theme: self.theme)
        self.displayNodeDidLoad()
    }
    
    private func addControllerIfNeeded() {
        if !controller.isViewLoaded || controller.view.superview == nil {
            self.displayNode.view.addSubview(controller.view)
            if let layout = self.validLayout {
                controller.view.frame = CGRect(origin: CGPoint(), size: layout.size)
            }
            controller.viewDidAppear(false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addControllerIfNeeded()
        controller.viewWillAppear(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        controller.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        controller.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        controller.viewDidDisappear(animated)
    }
    
    override func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
        
        self.validLayout = layout
        let controllerFrame = CGRect(origin: CGPoint(), size: layout.size)
        self.controller.defaultFrame = controllerFrame
        
        self.controllerNode.containerLayoutUpdated(layout, navigationBarHeight: 0.0, transition: transition)
        
        self.addControllerIfNeeded()
        if case .immediate = transition {
            self.controller.view.frame = controllerFrame
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.controller.view.frame = controllerFrame
            })
        }
    }
    
    private func activateLocalization(_ code: String) {
        let currentCode = self.accountManager.transaction { transaction -> String in
            if let current = transaction.getSharedData(SharedDataKeys.localizationSettings) as? LocalizationSettings {
                return current.primaryComponent.languageCode
            } else {
//                return "en"
                return HLAccountManager.shareLanguageCode.rawValue
            }
        }
        let suggestedCode = self.suggestedLocalization.get()
        |> map { localization -> String? in
            return localization?.availableLocalizations.first?.languageCode
        }
        
        let _ = (combineLatest(currentCode, suggestedCode)
        |> take(1)
        |> deliverOnMainQueue).start(next: { [weak self] currentCode, suggestedCode in
            guard let strongSelf = self else {
                return
            }
            
            if let suggestedCode = suggestedCode {
                _ = markSuggestedLocalizationAsSeenInteractively(postbox: strongSelf.postbox, languageCode: suggestedCode).start()
            }
            
            if currentCode == code {
                strongSelf.pressNext(strings: nil)
                return
            }
            
            strongSelf.controller.isEnabled = false
            let accountManager = strongSelf.accountManager
            let postbox = strongSelf.postbox
            
            strongSelf.activateLocalizationDisposable.set(downloadAndApplyLocalization(accountManager: accountManager, postbox: postbox, network: strongSelf.network, languageCode: code).start(completed: {
                let _ = (accountManager.transaction { transaction -> PresentationStrings? in
                    let localizationSettings: LocalizationSettings?
                    if let current = transaction.getSharedData(SharedDataKeys.localizationSettings) as? LocalizationSettings {
                        localizationSettings = current
                    } else {
                        localizationSettings = nil
                    }
                    let stringsValue: PresentationStrings
                    if let localizationSettings = localizationSettings {
                        
                        let languageCode = localizationSettings.primaryComponent.languageCode
                        print(languageCode)
                        switch LanguageCodeEnum(rawValue: languageCode) {
                        case .EN:
                            stringsValue = PresentationStrings(primaryComponent: PresentationStringsComponent(languageCode: languageCode, localizedName: "English", pluralizationRulesCode: nil, dict: NSDictionary(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: "en")!)) as! [String : String]), secondaryComponent: nil, groupingSeparator: "")
                        case .SC:
                            stringsValue = PresentationStrings(primaryComponent: PresentationStringsComponent(languageCode: languageCode, localizedName: "简体中文", pluralizationRulesCode: nil, dict: NSDictionary(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: "zh-Hans")!)) as! [String : String]), secondaryComponent: nil, groupingSeparator: "")
                        case .TC:
                            stringsValue = PresentationStrings(primaryComponent: PresentationStringsComponent(languageCode: languageCode, localizedName: "繁体中文", pluralizationRulesCode: nil, dict: NSDictionary(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: "zh-Hant")!)) as! [String : String]), secondaryComponent: nil, groupingSeparator: "")
                        case .none:
                           stringsValue = defaultPresentationStrings
                        }
//                        stringsValue = PresentationStrings(primaryComponent: PresentationStringsComponent(languageCode: localizationSettings.primaryComponent.languageCode, localizedName: localizationSettings.primaryComponent.localizedName, pluralizationRulesCode: localizationSettings.primaryComponent.customPluralizationCode, dict: dictFromLocalization(localizationSettings.primaryComponent.localization)), secondaryComponent: localizationSettings.secondaryComponent.flatMap({ PresentationStringsComponent(languageCode: $0.languageCode, localizedName: $0.localizedName, pluralizationRulesCode: $0.customPluralizationCode, dict: dictFromLocalization($0.localization)) }), groupingSeparator: "")
                    } else {
                        stringsValue = defaultPresentationStrings
                    }
                    return stringsValue
                }
                |> deliverOnMainQueue).start(next: { strings in
                    self?.controller.isEnabled = true
                    self?.pressNext(strings: strings)
                })
            }))
        })
    }
    
    private func pressNext(strings: PresentationStrings?) {
        if let navigationController = self.navigationController, navigationController.viewControllers.last === self {
            self.nextPressed?(strings)
        }
    }
}
