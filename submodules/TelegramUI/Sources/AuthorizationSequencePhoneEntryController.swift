import Foundation
import UIKit
import Display
import AsyncDisplayKit
import SwiftSignalKit
import TelegramCore
import SyncCore
import Postbox
import TelegramPresentationData
import ProgressNavigationButtonNode
import AccountContext
import CountrySelectionUI
import SettingsUI
import PhoneNumberFormat

import HL
import Network
import Repo
import Config
import UI
import RxSwift
import Model
import ViewModel

final class AuthorizationSequencePhoneEntryController: ViewController {
    private var controllerNode: AuthorizationSequencePhoneEntryControllerNode {
        return self.displayNode as! AuthorizationSequencePhoneEntryControllerNode
    }
    
    private let sharedContext: SharedAccountContext
    private var account: UnauthorizedAccount
    private let isTestingEnvironment: Bool
    private let otherAccountPhoneNumbers: ((String, AccountRecordId, Bool)?, [(String, AccountRecordId, Bool)])
    private let network: Network
    private let presentationData: PresentationData
    private let openUrl: (String) -> Void
    
    private let back: () -> Void
    
    private var currentData: (Int32, String?, String)?
    
    var inProgress: Bool = false {
        didSet {
            if self.inProgress {
//                let item = UIBarButtonItem(customDisplayNode: ProgressNavigationButtonNode(color: self.presentationData.theme.rootController.navigationBar.accentTextColor))
//                self.navigationItem.rightBarButtonItem = item
                HUD.show(.systemActivity, onView: self.view, dismiss: true, marginTop: false, marginBottom: false)
            } else {
//                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: self.presentationData.strings.Common_Next, style: .done, target: self, action: #selector(self.nextPressed))
                HUD.hide()
            }
            self.controllerNode.inProgress = self.inProgress
        }
    }
    var loginWithNumber: ((String, Bool) -> Void)?
    var accountUpdated: ((UnauthorizedAccount) -> Void)?
    
    private let termsDisposable = MetaDisposable()
    
    private let hapticFeedback = HapticFeedback()
    
    init(sharedContext: SharedAccountContext, account: UnauthorizedAccount, isTestingEnvironment: Bool, otherAccountPhoneNumbers: ((String, AccountRecordId, Bool)?, [(String, AccountRecordId, Bool)]), network: Network, presentationData: PresentationData, openUrl: @escaping (String) -> Void, back: @escaping () -> Void) {
        self.sharedContext = sharedContext
        self.account = account
        self.isTestingEnvironment = isTestingEnvironment
        self.otherAccountPhoneNumbers = otherAccountPhoneNumbers
        self.network = network
        self.presentationData = presentationData
        self.openUrl = openUrl
        self.back = back
        
        super.init(navigationBarPresentationData: NavigationBarPresentationData(theme: AuthorizationSequenceController.navigationBarTheme(presentationData.theme), strings: NavigationBarStrings(presentationStrings: presentationData.strings)))
        
        self.supportedOrientations = ViewControllerSupportedOrientations(regularSize: .all, compactSize: .portrait)
        
        self.hasActiveInput = true
        
        self.statusBar.statusBarStyle = presentationData.theme.intro.statusBarStyle.style
        self.attemptNavigation = { _ in
            return false
        }
        self.navigationBar?.backPressed = {
            back()
        }
        
        if !otherAccountPhoneNumbers.1.isEmpty {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: presentationData.strings.Common_Cancel, style: .plain, target: self, action: #selector(self.cancelPressed))
        }
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: presentationData.strings.Common_Next, style: .done, target: self, action: #selector(self.nextPressed))
        //登录海螺钱包
        self.controllerNode.loginHLWallet = {[weak self] in
            guard let self = self else {return}
            let assetVC = AssetVC(presentationData: presentationData)
            let pushAccountValidationVC : (Bool,Phone,Bool)->() = { (showPwdView,phone,canLoginWithPwd) in
                
//                let vc = AccountValidationVC(phone:phone, presentationData: presentationData, showPwdView: showPwdView, onValidateSuccess: {
//                    self.navigationController?.pushViewController(assetVC, animated: true)
//                })
                let vc = AccountValidationVC.create(presentationData: presentationData, showPwdView: showPwdView, phone: phone, canLoginWithPwd: canLoginWithPwd) { [weak self] in
                    self?.navigationController?.pushViewController(assetVC, animated: true)
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            AssetVerificationViewController.show(presentationData: presentationData, currentVC: self, onPushAccountLockVC: {
                let disableVC = AccountLockVC(presentationData: presentationData, title: $0)
                self.navigationController?.pushViewController(disableVC, animated: true)
            }, onPushAccountValidationVC: {
                pushAccountValidationVC($0,$1,$2)
            }, onPushBindExceptionVC: {
                let exceptionVM = BindExceptionVM(oldPhoneCode: $0, oldTelephone: $1, payPwdStatus: $2, onValidateSuccess: {})
                let exceptionVC = $0 == "1" ? BindExceptionPswVC(presentationData: presentationData, viewModel: exceptionVM) : BindExceptionCaptchaVC(presentationData: presentationData, viewModel: exceptionVM)
                self.navigationController?.pushViewController(exceptionVC, animated: true)
            })
        }
        
        self.controllerNode.login = {[weak self] in
            self?.nextPressed()
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.termsDisposable.dispose()
    }
    
    @objc private func cancelPressed() {
        self.back()
    }
    
    func updateData(countryCode: Int32, countryName: String?, number: String) {
        self.currentData = (countryCode, countryName, number)
        if self.isNodeLoaded {
            self.controllerNode.codeAndNumber = (countryCode, countryName, number)
        }
    }
    
    override public func loadDisplayNode() {
        self.displayNode = AuthorizationSequencePhoneEntryControllerNode(sharedContext: self.sharedContext, account: self.account, strings: self.presentationData.strings, theme: self.presentationData.theme, debugAction: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.view.endEditing(true)
            self?.present(debugController(sharedContext: strongSelf.sharedContext, context: nil, modal: true), in: .window(.root), with: ViewControllerPresentationArguments(presentationAnimation: .modalSheet))
            },switchProxyTap:{[weak self] in
                guard let self = self else{return}
                self.switchProxy()
        },hasOtherAccounts: self.otherAccountPhoneNumbers.0 != nil)
        self.controllerNode.accountUpdated = { [weak self] account in
            guard let strongSelf = self else {
                return
            }
            strongSelf.account = account
            strongSelf.accountUpdated?(account)
        }
        
        if let (code, name, number) = self.currentData {
            self.controllerNode.codeAndNumber = (code, name, number)
        }
        self.displayNodeDidLoad()
        
        self.controllerNode.view.disableAutomaticKeyboardHandling = [.forward, .backward]
        
        self.controllerNode.selectCountryCode = { [weak self] in
            if let strongSelf = self {
                let controller = AuthorizationSequenceCountrySelectionController(strings: strongSelf.presentationData.strings, theme: strongSelf.presentationData.theme)
                controller.completeWithCountryCode = { code, name in
                    if let strongSelf = self, let currentData = strongSelf.currentData {
                        strongSelf.updateData(countryCode: Int32(code), countryName: name, number: currentData.2)
                        strongSelf.controllerNode.activateInput()
                    }
                }
                controller.dismissed = {
                    self?.controllerNode.activateInput()
                }
                strongSelf.push(controller)
            }
        }
        self.controllerNode.checkPhone = { [weak self] in
            self?.nextPressed()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.controllerNode.activateInput()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.controllerNode.activateInput()
    }
    
    override func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
        
        self.controllerNode.containerLayoutUpdated(layout, navigationBarHeight: self.navigationHeight, transition: transition)
    }
    
    //增加跳转代理
    @objc func switchProxy(){
        let vc = proxySettingsController(accountManager: sharedContext.accountManager, context: nil, postbox: account.postbox, network: network, mode: .modal, presentationData: presentationData, updatedPresentationData: sharedContext.presentationData)
        (self.navigationController as? NavigationController)?.pushViewController(vc)
    }
    
    private let repo = InvitationRepo()
    private var disposeBag: DisposeBag!
    @objc func nextPressed() {
        
        //判断是否勾选已经同意先关协议
        guard self.controllerNode.hadAgree else {
            self.controllerNode.notAgreeAnimateError()
            return
        }
        
        //判断电话是否为空
        let (phoneCode, _, telephone) = self.controllerNode.codeAndNumber
                
        guard !telephone.isEmpty else {
            hapticFeedback.error()
            self.controllerNode.animateError()
            return
        }
        
        disposeBag = DisposeBag()
        
        //项目配置，是否输入邀请码
        if APPConfig.needCheckInvitationCode {

            //判断是否已经输入过邀请码
            repo.check(phoneCode: "\(phoneCode ?? 86)", telephone: telephone)
                .value({[weak self] _ in
                    self?.nextForlogin()
                })
                .netWorkState({[weak self] in
                    guard let self = self else {return}
                    switch $0{
                    case .success:
                        HUD.hide()
                    case .loading:
                        HUD.show(.systemActivity, onView: self.view)
                    case let .error(error):
                        guard error.code == 100001 else {
                            HUD.flash(.label(error.msg), delay: 1)
                            return
                        }

                        HUD.hide()
                        InvitationAlertNode.show(from: self,phoneCode: "\(phoneCode ?? 86)", telephone: telephone) {[weak self] in
                            self?.nextForlogin()
                        }
                    }
                })
                .load(disposeBag)
        }else{
            self.nextForlogin()
        }
        
        /* 白名单暂时屏蔽
        repo.whitelistCheck(telephone: telephone, phoneCode: "\(phoneCode ?? 86)")
            .observeObject({[weak self] _ in
                self?.nextForlogin()
            })
            .netWorkState({[weak self] in
                guard let self = self else {return}
                switch $0{
                case .success:
                    HUD.hide()
                case .loading:
                    HUD.show(.systemActivity, onView: self.view)
                case .error:
                    break
                }
            })
            .error({
                HUD.flash(.label($0.message), delay: 1)
            })
            .load(disposeBag)
         */
    }
    
    func nextForlogin() {
        let (_, _, number) = self.controllerNode.codeAndNumber
        if !number.isEmpty {
            let logInNumber = formatPhoneNumber(self.controllerNode.currentNumber)
            var existing: (String, AccountRecordId)?
            for (number, id, isTestingEnvironment) in self.otherAccountPhoneNumbers.1 {
                if isTestingEnvironment == self.isTestingEnvironment && formatPhoneNumber(number) == logInNumber {
                    existing = (number, id)
                }
            }
            
            if let (_, id) = existing {
                var actions: [TextAlertAction] = []
                if let (current, _, _) = self.otherAccountPhoneNumbers.0, logInNumber != formatPhoneNumber(current) {
                    actions.append(TextAlertAction(type: .genericAction, title: self.presentationData.strings.Login_PhoneNumberAlreadyAuthorizedSwitch, action: { [weak self] in
                        self?.sharedContext.switchToAccount(id: id, fromSettingsController: nil, withChatListController: nil)
                        self?.back()
                    }))
                }
                actions.append(TextAlertAction(type: .defaultAction, title: self.presentationData.strings.Common_OK, action: {}))
                self.present(standardTextAlertController(theme: AlertControllerTheme(presentationData: self.presentationData), title: nil, text: self.presentationData.strings.Login_PhoneNumberAlreadyAuthorized, actions: actions), in: .window(.root))
            } else {
                self.loginWithNumber?(self.controllerNode.currentNumber, self.controllerNode.syncContacts)
            }
        } else {
            hapticFeedback.error()
            self.controllerNode.animateError()
        }
    }
}
