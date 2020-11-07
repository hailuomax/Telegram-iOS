import Foundation
import UIKit
import AsyncDisplayKit
import Display
import TelegramCore
import SyncCore
import TelegramPresentationData
import PhoneInputNode
import CountrySelectionUI
import AuthorizationUI
import QrCode
import SwiftSignalKit
import Postbox
import AccountContext

import Language
import Extension
import Config
import Repo
import UI
import HL

private func emojiFlagForISOCountryCode(_ countryCode: NSString) -> String {
    if countryCode.length != 2 {
        return ""
    }
    
    let base: UInt32 = 127462 - 65
    let first: UInt32 = base + UInt32(countryCode.character(at: 0))
    let second: UInt32 = base + UInt32(countryCode.character(at: 1))
    
    var data = Data()
    data.count = 8
    data.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<UInt32>) -> Void in
        bytes[0] = first
        bytes[1] = second
    }
    return String(data: data, encoding: String.Encoding.utf32LittleEndian) ?? ""
}

private final class PhoneAndCountryNode: ASDisplayNode {
    let strings: PresentationStrings
    let countryButton: ASButtonNode
    let phoneBackground: ASImageNode
    let phoneInputNode: PhoneInputNode
    
    var selectCountryCode: (() -> Void)?
    var checkPhone: (() -> Void)?
    var loginHLWallet: (() -> Void)?
    
    let loginHlWalletButtonTitle = "切换海螺钱包账号登录"
    //是否都输入
    var numberAndCountryIsInput : Bool {
        return !phoneInputNode.countryCodeText.isEmpty && !phoneInputNode.numberText.isEmpty
    }
    
    //登录海螺钱包
    let loginHlWalletButton: ASButtonNode
    
    private let countryBottomLine: ASDisplayNode
    private let numberBottomLine: ASDisplayNode
    private let arrowImageNode: ASImageNode
    
    init(strings: PresentationStrings, theme: PresentationTheme) {
        self.strings = strings
        
//        let countryButtonBackground = generateImage(CGSize(width: 61.0, height: 67.0), rotatedContext: { size, context in
//            let arrowSize: CGFloat = 10.0
//            let lineWidth = UIScreenPixel
//            context.clear(CGRect(origin: CGPoint(), size: size))
//            context.setStrokeColor(theme.list.itemPlainSeparatorColor.cgColor)
//            context.setLineWidth(lineWidth)
//            context.move(to: CGPoint(x: 15.0, y: lineWidth / 2.0))
//            context.addLine(to: CGPoint(x: size.width, y: lineWidth / 2.0))
//            context.strokePath()
//
//            context.move(to: CGPoint(x: size.width, y: size.height - arrowSize - lineWidth / 2.0))
//            context.addLine(to: CGPoint(x: size.width - 1.0, y: size.height - arrowSize - lineWidth / 2.0))
//            context.addLine(to: CGPoint(x: size.width - 1.0 - arrowSize, y: size.height - lineWidth / 2.0))
//            context.addLine(to: CGPoint(x: size.width - 1.0 - arrowSize - arrowSize, y: size.height - arrowSize - lineWidth / 2.0))
//            context.addLine(to: CGPoint(x: 15.0, y: size.height - arrowSize - lineWidth / 2.0))
//            context.strokePath()
//        })?.stretchableImage(withLeftCapWidth: 61, topCapHeight: 1)
//
//        let countryButtonHighlightedBackground = generateImage(CGSize(width: 60.0, height: 67.0), rotatedContext: { size, context in
//            let arrowSize: CGFloat = 10.0
//            context.clear(CGRect(origin: CGPoint(), size: size))
//            context.setFillColor(theme.list.itemHighlightedBackgroundColor.cgColor)
//            context.fill(CGRect(origin: CGPoint(), size: CGSize(width: size.width, height: size.height - arrowSize)))
//            context.move(to: CGPoint(x: size.width, y: size.height - arrowSize))
//            context.addLine(to: CGPoint(x: size.width - 1.0, y: size.height - arrowSize))
//            context.addLine(to: CGPoint(x: size.width - 1.0 - arrowSize, y: size.height))
//            context.addLine(to: CGPoint(x: size.width - 1.0 - arrowSize - arrowSize, y: size.height - arrowSize))
//            context.closePath()
//            context.fillPath()
//        })?.stretchableImage(withLeftCapWidth: 61, topCapHeight: 2)
//
//        let phoneInputBackground = generateImage(CGSize(width: 85.0, height: 57.0), rotatedContext: { size, context in
//            let lineWidth = UIScreenPixel
//            context.clear(CGRect(origin: CGPoint(), size: size))
//            context.setStrokeColor(theme.list.itemPlainSeparatorColor.cgColor)
//            context.setLineWidth(lineWidth)
//            context.move(to: CGPoint(x: 15.0, y: size.height - lineWidth / 2.0))
//            context.addLine(to: CGPoint(x: size.width, y: size.height - lineWidth / 2.0))
//            context.strokePath()
//            context.move(to: CGPoint(x: size.width - 2.0 + lineWidth / 2.0, y: size.height - lineWidth / 2.0))
//            context.addLine(to: CGPoint(x: size.width - 2.0 + lineWidth / 2.0, y: 0.0))
//            context.strokePath()
//        })?.stretchableImage(withLeftCapWidth: 84, topCapHeight: 2)
        
        self.countryButton = ASButtonNode()
        self.countryButton.displaysAsynchronously = false
//        self.countryButton.setBackgroundImage(countryButtonBackground, for: [])
//        self.countryButton.titleNode.maximumNumberOfLines = 1
//        self.countryButton.titleNode.truncationMode = .byTruncatingTail
//        self.countryButton.setBackgroundImage(countryButtonHighlightedBackground, for: .highlighted)
        
        self.phoneBackground = ASImageNode()
//        self.phoneBackground.image = phoneInputBackground
        self.phoneBackground.displaysAsynchronously = false
        self.phoneBackground.displayWithoutProcessing = true
        self.phoneBackground.isLayerBacked = true
        
        self.phoneInputNode = PhoneInputNode()
        
        self.loginHlWalletButton = ASButtonNode()
        self.countryBottomLine = ASDisplayNode()
        self.numberBottomLine = ASDisplayNode()
        self.arrowImageNode = ASImageNode()
        
        super.init()
        
//        self.addSubnode(self.phoneBackground)
        self.addSubnode(self.phoneInputNode)
//        self.addSubnode(self.loginHlWalletButton)
        self.addSubnode(self.countryButton)
        self.addSubnode(self.countryBottomLine)
        self.addSubnode(self.numberBottomLine)
        self.countryButton.addSubnode(self.arrowImageNode)
        
        self.arrowImageNode.image = UIImage(bundleImageName: "down_arrow")
        self.countryBottomLine.backgroundColor = UIColor(hexString: "#EBEBEB")
        self.numberBottomLine.backgroundColor = UIColor(hexString: "#EBEBEB")
        
        self.loginHlWalletButton.setTitle(loginHlWalletButtonTitle, with: UIFont.systemFont(ofSize: 13), with: UIColor(hexString: "#3F83FF")!, for: .normal)
        
        self.phoneInputNode.countryCodeField.textField.keyboardAppearance = theme.rootController.keyboardColor.keyboardAppearance
        self.phoneInputNode.numberField.textField.keyboardAppearance = theme.rootController.keyboardColor.keyboardAppearance
        self.phoneInputNode.countryCodeField.textField.textColor = theme.list.itemPrimaryTextColor
        self.phoneInputNode.numberField.textField.textColor = theme.list.itemPrimaryTextColor
        self.phoneInputNode.countryCodeField.textField.tintColor = theme.list.itemAccentColor
        self.phoneInputNode.numberField.textField.tintColor = theme.list.itemAccentColor
        
        self.phoneInputNode.countryCodeField.textField.tintColor = theme.list.itemAccentColor
        self.phoneInputNode.numberField.textField.tintColor = theme.list.itemAccentColor
        
        self.phoneInputNode.countryCodeField.textField.disableAutomaticKeyboardHandling = [.forward]
        self.phoneInputNode.numberField.textField.disableAutomaticKeyboardHandling = [.forward]
        
//        self.countryButton.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 15.0, bottom: 10.0, right: 0.0)
//        self.countryButton.contentHorizontalAlignment = .left
        
        self.phoneInputNode.numberField.textField.attributedPlaceholder = NSAttributedString(string: "请确认国际电话区号并输入手机号码", font: Font.regular(14.0), textColor: theme.list.itemPlaceholderTextColor)
        
        self.countryButton.addTarget(self, action: #selector(self.countryPressed), forControlEvents: .touchUpInside)
        
        self.loginHlWalletButton.addTarget(self, action: #selector(self.clickLoginHLWalletButton), forControlEvents: .touchUpInside)
        
        self.phoneInputNode.countryCodeUpdated = { [weak self] code, name in
            if let strongSelf = self {
                if let code = Int(code), let name = name, let countryName = countryCodeAndIdToName[CountryCodeAndId(code: code, id: name)] {
                    let flagString = emojiFlagForISOCountryCode(name as NSString)
                    let localizedName: String = AuthorizationSequenceCountrySelectionController.lookupCountryNameById(name, strings: strongSelf.strings) ?? countryName
//                    strongSelf.countryButton.setTitle("\(flagString) \(localizedName)", with: Font.regular(20.0), with: theme.list.itemPrimaryTextColor, for: [])
                } else if let code = Int(code), let (countryId, countryName) = countryCodeToIdAndName[code] {
                    let flagString = emojiFlagForISOCountryCode(countryId as NSString)
                    let localizedName: String = AuthorizationSequenceCountrySelectionController.lookupCountryNameById(countryId, strings: strongSelf.strings) ?? countryName
//                    strongSelf.countryButton.setTitle("\(flagString) \(localizedName)", with: Font.regular(20.0), with: theme.list.itemPrimaryTextColor, for: [])
                } else {
//                    strongSelf.countryButton.setTitle(strings.Login_SelectCountry_Title, with: Font.regular(20.0), with: theme.list.itemPlaceholderTextColor, for: [])
                }
            }
        }
        
        self.phoneInputNode.number = "+1"
        self.phoneInputNode.returnAction = { [weak self] in
            self?.checkPhone?()
        }
        
    }
    
    @objc func countryPressed() {
        self.selectCountryCode?()
    }
    
    @objc func clickLoginHLWalletButton() {
        self.loginHLWallet?()
    }
    
    override func layout() {
        super.layout()
        
        let size = self.bounds.size
        
//        self.phoneBackground.frame = CGRect(origin: CGPoint(x: 0.0, y: size.height - 57.0), size: CGSize(width: size.width, height: 57.0))
        let inputHeight: CGFloat = 44
        let countryCodeFrame = CGRect(origin: CGPoint(x: 25, y: 0), size: CGSize(width: 60.0, height: inputHeight))
        let numberFrame = CGRect(origin: CGPoint(x: 110, y: 0), size: CGSize(width: size.width - 110 - 25, height: inputHeight))
        
        let phoneInputFrame = countryCodeFrame.union(numberFrame)
        
        self.phoneInputNode.frame = phoneInputFrame
        self.phoneInputNode.countryCodeField.frame = countryCodeFrame.offsetBy(dx: -phoneInputFrame.minX, dy: -phoneInputFrame.minY)
        self.phoneInputNode.numberField.frame = numberFrame.offsetBy(dx: -phoneInputFrame.minX, dy: -phoneInputFrame.minY)
        
        self.countryButton.frame = CGRect(origin: countryCodeFrame.origin, size: self.phoneInputNode.countryCodeField.frame.size)
        
        let fitSize = loginHlWalletButtonTitle.sizeWithConstrainedWidth(size.width, font: UIFont.systemFont(ofSize: 13))
        self.loginHlWalletButton.frame = CGRect(x: 25, y: inputHeight + 20, width: fitSize.width, height: 20)
        
        self.countryBottomLine.frame = CGRect(x: 25, y: inputHeight, width: 67.0, height: 0.5)
        self.numberBottomLine.frame = CGRect(x: 110, y: inputHeight, width: numberFrame.width, height: 0.5)
        
        self.arrowImageNode.frame = CGRect(x: 60 - 5, y: (inputHeight - 9) / 2, width: 12, height: 9)
    }
}

private final class ContactSyncNode: ASDisplayNode {
    private let titleNode: ImmediateTextNode
    let switchNode: SwitchNode
    
    init(theme: PresentationTheme, strings: PresentationStrings) {
        self.titleNode = ImmediateTextNode()
        self.titleNode.maximumNumberOfLines = 1
        self.titleNode.attributedText = NSAttributedString(string: strings.Privacy_ContactsSync, font: Font.regular(17.0), textColor: theme.list.itemPrimaryTextColor)
        self.switchNode = SwitchNode()
        self.switchNode.frameColor = theme.list.itemSwitchColors.frameColor
        self.switchNode.contentColor = theme.list.itemSwitchColors.contentColor
        self.switchNode.handleColor = theme.list.itemSwitchColors.handleColor
        self.switchNode.isOn = true
        
        super.init()
        
        self.addSubnode(self.titleNode)
        self.addSubnode(self.switchNode)
    
    }
    
    func updateLayout(width: CGFloat) -> CGSize {
        let switchSize = CGSize(width: 51.0, height: 31.0)
        let titleSize = self.titleNode.updateLayout(CGSize(width: width - switchSize.width - 16.0 * 2.0 - 8.0, height: .greatestFiniteMagnitude))
        let height: CGFloat = 40.0
        self.titleNode.frame = CGRect(origin: CGPoint(x: 16.0, y: floor((height - titleSize.height) / 2.0)), size: titleSize)
        self.switchNode.frame = CGRect(origin: CGPoint(x: width - 16.0 - switchSize.width, y: floor((height - switchSize.height) / 2.0)), size: switchSize)
        return CGSize(width: width, height: height)
    }
}

final class AuthorizationSequencePhoneEntryControllerNode: ASDisplayNode {
    private let sharedContext: SharedAccountContext
    private var account: UnauthorizedAccount
    private let strings: PresentationStrings
    private let theme: PresentationTheme
    private let hasOtherAccounts: Bool
    
    private let titleNode: ASTextNode
    private let noticeNode: ASTextNode
    private let phoneAndCountryNode: PhoneAndCountryNode
    private let contactSyncNode: ContactSyncNode
    
    private var qrNode: ASImageNode?
    private let exportTokenDisposable = MetaDisposable()
    private let tokenEventsDisposable = MetaDisposable()
    var accountUpdated: ((UnauthorizedAccount) -> Void)?
    
    private let debugAction: () -> Void
    // 当前号码
    var currentNumber: String {
        return self.phoneAndCountryNode.phoneInputNode.number
    }
    
    var codeAndNumber: (Int32?, String?, String) {
        get {
            return self.phoneAndCountryNode.phoneInputNode.codeAndNumber
        } set(value) {
            self.phoneAndCountryNode.phoneInputNode.codeAndNumber = value
        }
    }
    
    var syncContacts: Bool {
        get {
            if self.hasOtherAccounts {
                return self.contactSyncNode.switchNode.isOn
            } else {
                return true
            }
        }
    }
    
    var selectCountryCode: (() -> Void)?
    var checkPhone: (() -> Void)?
    var login: (() -> Void)?
    
    var inProgress: Bool = false {
        didSet {
            self.phoneAndCountryNode.phoneInputNode.enableEditing = !self.inProgress
            self.phoneAndCountryNode.phoneInputNode.alpha = self.inProgress ? 0.6 : 1.0
            self.phoneAndCountryNode.countryButton.isEnabled = !self.inProgress
        }
    }
    
    private let switchProxyTap : ()->Void
    /// 是否已同意先关协议
    private(set) var hadAgree: Bool = true
    ///协议内容行
    private lazy var protocolNode: ProtocolContentNode = {
        let node = ProtocolContentNode{ [weak self] in
            guard let self = self else {return}
            self.hadAgree = $0
        }
        node.frame = CGRect(x: 16, y: 0, width: 0, height: 0)
        return node
    }()
    
    ///跳转代理button
    private lazy var proxyNode: ASButtonNode = {
        let node = ASButtonNode()
        node.setTitle(HLLanguage.SwitchProxy.localized(), with: FontEnum.k_pingFangSC_Regular.toFont(15), with: UIColor(hexString: "#3F83FF")!, for: .normal)
        node.addTarget(self, action: #selector(proxyButtonTap), forControlEvents: ASControlNodeEvent.touchUpInside)
        node.frame = CGRect(x: 34, y: 0, width: 100, height: 20)
        return node
    }()
    
    ///logo
    private lazy var iconNode: ASImageNode = {
        let node = ASImageNode()
        node.image = UIImage(bundleImageName: "login_icon")
        node.frame = CGRect(x: 34, y: 0, width: 70, height: 54)
        node.contentMode = .scaleToFill
        return node
    }()
    
    //确认按钮
    private lazy var confirmButton: ASButtonNode = {
        let btn = ASButtonNode ()
        btn.setTitle("确认", with: UIFont.systemFont(ofSize: 18), with: UIColor(hexString: "#FFFFFF")!, for: .normal)
        return btn
    }()
    
    var loginHLWallet: (() -> Void)?
    
    
    init(sharedContext: SharedAccountContext, account: UnauthorizedAccount, strings: PresentationStrings, theme: PresentationTheme, debugAction: @escaping () -> Void,switchProxyTap:@escaping () -> Void, hasOtherAccounts: Bool) {
        self.sharedContext = sharedContext
        self.account = account
        
        self.strings = strings
        self.theme = theme
        self.debugAction = debugAction
        self.hasOtherAccounts = hasOtherAccounts
        
        self.titleNode = ASTextNode()
        self.titleNode.isUserInteractionEnabled = true
        self.titleNode.displaysAsynchronously = false
        self.titleNode.attributedText = NSAttributedString(string: strings.Login_PhoneTitle, font: Font.light(30.0), textColor: theme.list.itemPrimaryTextColor)
        
        self.noticeNode = ASTextNode()
//        self.noticeNode.maximumNumberOfLines = 0
//        self.noticeNode.isUserInteractionEnabled = true
//        self.noticeNode.displaysAsynchronously = false
//        self.titleNode.attributedText = NSAttributedString(string: strings.Login_PhoneTitle, font: Font.light(30.0), textColor: theme.list.itemPrimaryTextColor)
        
        self.contactSyncNode = ContactSyncNode(theme: theme, strings: strings)
        
        self.phoneAndCountryNode = PhoneAndCountryNode(strings: strings, theme: theme)
        
        self.switchProxyTap = switchProxyTap
        
        super.init()
        
        self.setViewBlock({
            return UITracingLayerView()
        })
        
        self.backgroundColor = theme.list.plainBackgroundColor
        self.confirmButton.layer.cornerRadius = 6
        self.confirmButton.layer.masksToBounds = true
        
        self.addSubnode(self.titleNode)
        self.addSubnode(self.noticeNode)
        self.addSubnode(self.phoneAndCountryNode)
        self.addSubnode(self.contactSyncNode)
        self.addSubnode(self.protocolNode)
        self.addSubnode(self.iconNode)
        self.addSubnode(self.proxyNode)
        
        self.addSubnode(confirmButton)
        
        self.contactSyncNode.isHidden = true
        
        self.phoneAndCountryNode.selectCountryCode = { [weak self] in
            self?.selectCountryCode?()
        }
        self.phoneAndCountryNode.checkPhone = { [weak self] in
            self?.checkPhone?()
        }
        self.phoneAndCountryNode.loginHLWallet = {[weak self] in
            self?.loginHLWallet?()
        }
        
        self.phoneAndCountryNode.phoneInputNode.numberTextUpdated = {[weak self] in
            guard let self = self else {return}
            self.confirmButton.isEnabled = !$0.isEmpty
            let colors : [UIColor]
            if $0.isEmpty {
                colors = [UIColor.hex(.kA1D3FB),UIColor.hex(.k91BFFA)]
            }else {
                colors = [UIColor.hex(.k4FB8FF),UIColor.hex(.k3493FF)]
            }
            let image = UIImage.setGradientImageWithBounds(rect:CGRect(origin: CGPoint.zero, size: self.confirmButton.frame.size) , colors: colors, type: 1)
            self.confirmButton.backgroundImageNode.image = image
        }
        
        self.tokenEventsDisposable.set((account.updateLoginTokenEvents
        |> deliverOnMainQueue).start(next: { [weak self] _ in
            self?.refreshQrToken()
        }))
        
    }
    
    deinit {
        self.exportTokenDisposable.dispose()
        self.tokenEventsDisposable.dispose()
    }
    
    override func didLoad() {
        super.didLoad()
        let image = UIImage.setGradientImageWithBounds(rect:CGRect(origin: CGPoint.zero, size: CGSize(width: self.frame.size.width - 50, height: 50)) , colors: [UIColor.hex(.kA1D3FB),UIColor.hex(.k91BFFA)], type: 1)
        confirmButton.backgroundImageNode.image = image
        
        confirmButton.addTarget(self, action: #selector(clickComfirmButton), forControlEvents: .touchUpInside)
        self.titleNode.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.debugTap(_:))))
        #if DEBUG
        self.noticeNode.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.debugQrTap(_:))))
        #endif
    }
    
    
    func containerLayoutUpdated(_ layout: ContainerViewLayout, navigationBarHeight: CGFloat, transition: ContainedViewLayoutTransition) {
        var insets = layout.insets(options: [])
        insets.top = navigationBarHeight
        
        if let inputHeight = layout.inputHeight, !inputHeight.isZero {
            insets.bottom += max(inputHeight, layout.standardInputHeight)
        }
        
//        if max(layout.size.width, layout.size.height) > 1023.0 {
//            self.titleNode.attributedText = NSAttributedString(string: HLLanguage.HaiLuoAccountLogin.localized(), font: Font.light(40.0), textColor: self.theme.list.itemPrimaryTextColor)
//        } else {
//            self.titleNode.attributedText = NSAttributedString(string: strings.Login_PhoneTitle, font: Font.light(30.0), textColor: self.theme.list.itemPrimaryTextColor)
//        }
//
//        let titleSize = self.titleNode.measure(CGSize(width: layout.size.width, height: CGFloat.greatestFiniteMagnitude))
//        let noticeSize = self.noticeNode.measure(CGSize(width: min(274.0, layout.size.width - 28.0), height: CGFloat.greatestFiniteMagnitude))
        
        var items: [AuthorizationLayoutItem] = [
            AuthorizationLayoutItem(node: self.iconNode, size: CGSize(width: 60, height: 75), spacingBefore: AuthorizationLayoutItemSpacing(weight: 0.0, maxValue: 0.0), spacingAfter: AuthorizationLayoutItemSpacing(weight: 10.0, maxValue: 10.0)),
            AuthorizationLayoutItem(node: self.proxyNode, size: CGSize(width: 100, height: 20), spacingBefore: AuthorizationLayoutItemSpacing(weight: 10.0, maxValue: 10.0), spacingAfter: AuthorizationLayoutItemSpacing(weight: 0.0, maxValue: 0.0)),
            AuthorizationLayoutItem(node: self.phoneAndCountryNode, size: CGSize(width: layout.size.width, height: 44), spacingBefore: AuthorizationLayoutItemSpacing(weight: 30, maxValue: 30), spacingAfter: AuthorizationLayoutItemSpacing(weight: 0.0, maxValue: 0.0)),
            AuthorizationLayoutItem(node: self.confirmButton, size: CGSize(width: layout.size.width - 50, height: 50), spacingBefore: AuthorizationLayoutItemSpacing(weight: 50, maxValue: 50), spacingAfter: AuthorizationLayoutItemSpacing(weight: 0.0, maxValue: 0.0))
        ]
        let contactSyncSize = self.contactSyncNode.updateLayout(width: layout.size.width)

        // layout.size.height - insets.top - insets.bottom - 10.0
        let _ = layoutAuthorizationItems(bounds: CGRect(origin: CGPoint(x: 0.0, y: insets.top), size: CGSize(width: layout.size.width, height: 310)), items: items, transition: transition, failIfDoesNotFit: false)
        
//        let protocolSize = self.protocolNode.measure(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        self.protocolNode.frame = CGRect(origin: CGPoint(x: 0, y: self.bounds.size.height - insets.bottom - 30 ), size: CGSize(width: layout.size.width - 10, height: 30))
        
        let colors : [UIColor]
        if !phoneAndCountryNode.numberAndCountryIsInput {
            colors = [UIColor.hex(.kA1D3FB),UIColor.hex(.k91BFFA)]
        }else {
            colors = [UIColor.hex(.k4FB8FF),UIColor.hex(.k3493FF)]
        }
        let image = UIImage.setGradientImageWithBounds(rect:CGRect(origin: CGPoint.zero, size: self.confirmButton.frame.size) , colors: colors, type: 1)
        self.confirmButton.backgroundImageNode.image = image
        
        
    }
    
    func activateInput() {
        self.phoneAndCountryNode.phoneInputNode.numberField.textField.becomeFirstResponder()
    }
    
    func animateError() {
        self.phoneAndCountryNode.phoneInputNode.countryCodeField.layer.addShakeAnimation()
        self.phoneAndCountryNode.phoneInputNode.numberField.layer.addShakeAnimation()
    }
    
    /// 未勾选同意相关协议时的抖动动画
    func notAgreeAnimateError(){
        self.protocolNode.layer.addShakeAnimation()
    }
    
    @objc private func proxyButtonTap(){
        
        self.switchProxyTap()
        
    }
    
    @objc private func clickComfirmButton(){
        self.login?()
    }
    
    private var debugTapCounter: (Double, Int) = (0.0, 0)
    @objc private func debugTap(_ recognizer: UITapGestureRecognizer) {
        if case .ended = recognizer.state {
            let timestamp = CACurrentMediaTime()
            if self.debugTapCounter.0 < timestamp - 0.4 {
                self.debugTapCounter.0 = timestamp
                self.debugTapCounter.1 = 0
            }
            
            if self.debugTapCounter.0 >= timestamp - 0.4 {
                self.debugTapCounter.0 = timestamp
                self.debugTapCounter.1 += 1
            }
            
            if self.debugTapCounter.1 >= 10 {
                self.debugTapCounter.1 = 0
                
                self.debugAction()
            }
        }
    }
    
    @objc private func debugQrTap(_ recognizer: UITapGestureRecognizer) {
        if self.qrNode == nil {
            let qrNode = ASImageNode()
            qrNode.frame = CGRect(origin: CGPoint(x: 16.0, y: 64.0 + 16.0), size: CGSize(width: 200.0, height: 200.0))
            self.qrNode = qrNode
            self.addSubnode(qrNode)
            
            self.refreshQrToken()
        }
    }
    
    private func refreshQrToken() {
        let sharedContext = self.sharedContext
        let account = self.account
        let tokenSignal = sharedContext.activeAccounts
            |> castError(ExportAuthTransferTokenError.self)
        |> take(1)
        |> mapToSignal { activeAccountsAndInfo -> Signal<ExportAuthTransferTokenResult, ExportAuthTransferTokenError> in
            let (primary, activeAccounts, _) = activeAccountsAndInfo
            var activeProductionUserIds = activeAccounts.map({ $0.1 }).filter({ !$0.testingEnvironment }).map({ $0.peerId.id })
            var activeTestingUserIds = activeAccounts.map({ $0.1 }).filter({ $0.testingEnvironment }).map({ $0.peerId.id })
            
            let allProductionUserIds = activeProductionUserIds
            let allTestingUserIds = activeTestingUserIds
            
            return exportAuthTransferToken(accountManager: sharedContext.accountManager, account: account, otherAccountUserIds: account.testingEnvironment ? allTestingUserIds : allProductionUserIds, syncContacts: true)
        }
        
        self.exportTokenDisposable.set((tokenSignal
        |> deliverOnMainQueue).start(next: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case let .displayToken(token):
                var tokenString = token.value.base64EncodedString()
                print("export token \(tokenString)")
                tokenString = tokenString.replacingOccurrences(of: "+", with: "-")
                tokenString = tokenString.replacingOccurrences(of: "/", with: "_")
                let urlString = "tg://login?token=\(tokenString)"
                let _ = (qrCode(string: urlString, color: .black, backgroundColor: .white, icon: .none)
                |> deliverOnMainQueue).start(next: { _, generate in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    let context = generate(TransformImageArguments(corners: ImageCorners(), imageSize: CGSize(width: 200.0, height: 200.0), boundingSize: CGSize(width: 200.0, height: 200.0), intrinsicInsets: UIEdgeInsets()))
                    if let image = context?.generateImage() {
                        strongSelf.qrNode?.image = image
                    }
                })
                
                let timestamp = Int32(Date().timeIntervalSince1970)
                let timeout = max(5, token.validUntil - timestamp)
                strongSelf.exportTokenDisposable.set((Signal<Never, NoError>.complete()
                |> delay(Double(timeout), queue: .mainQueue())).start(completed: {
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.refreshQrToken()
                }))
            case let .changeAccountAndRetry(account):
                strongSelf.exportTokenDisposable.set(nil)
                strongSelf.account = account
                strongSelf.accountUpdated?(account)
                strongSelf.tokenEventsDisposable.set((account.updateLoginTokenEvents
                |> deliverOnMainQueue).start(next: { _ in
                    self?.refreshQrToken()
                }))
                strongSelf.refreshQrToken()
            case .loggedIn, .passwordRequested:
                strongSelf.exportTokenDisposable.set(nil)
            }
        }))
    }
}

//MARK: - ProtocolContentNode
private class ProtocolContentNode: ASControlNode{
    
    private lazy var imgNode : ASButtonNode = {
        let node = ASButtonNode()
        node.imageNode.image = UIImage(bundleImageName: "loginAgree")
        node.imageNode.contentMode = .scaleAspectFill
        return node
    }()
    
    /// 协议文本内容
    private lazy var textNode : ASTextNode = ASTextNode()
    private lazy var buttonNode : ASButtonNode = ASButtonNode()
    
    /// 同意协议与否回调
    private let onAgreeOrNot : (Bool)->()
    
    init(onAgreeOrNot : @escaping (Bool)->()) {
        self.onAgreeOrNot = onAgreeOrNot
        super.init()
        self.isUserInteractionEnabled = true
        [buttonNode, imgNode,textNode].forEach {
            self.addSubnode($0)
        }
        self.setUpProtocolNode()
        self.textNode.isUserInteractionEnabled = false
        self.imgNode.addTarget(self, action: #selector(changeAgreeStatus), forControlEvents: ASControlNodeEvent.touchUpInside)
        buttonNode.addTarget(self, action: #selector(clickAgree), forControlEvents: ASControlNodeEvent.touchUpInside)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let maxWidth = constrainedSize.max.width
        let maxHeight = constrainedSize.max.height
        
        if let h = imgNode.imageNode.image?.size.height ,let w = imgNode.imageNode.image?.size.width {
            let fixSize = CGSize(width: maxWidth, height: 20)
            let titleFitsSize = textNode.calculateSizeThatFits(fixSize)
            let x = (maxWidth - titleFitsSize.width - w - 5) / 2
            let y = (maxHeight - h) - 10
            
            imgNode.frame = CGRect(x:x, y:y ,width: w, height: h)
            textNode.frame = CGRect(x:x + w + 5, y:y ,width: titleFitsSize.width, height: titleFitsSize.height)
            buttonNode.frame = textNode.frame
        }
        
        return ASLayoutSpec()
    }
    
    func setUpProtocolNode() {
        let font = UIFont.systemFont(ofSize: 10)
        let fontBlueColor = UIColor.hex(.kBlue)
        let fontBlackColor = UIColor.hex(.k878B9F)
        
        /// 协议链接标签的样式 attributes(link, textColor)  link:点击跳转的url
        let attributes : (String, UIColor)->[NSAttributedString.Key : Any] = { link, textColor in
            let rtn : [NSAttributedString.Key : Any] = [
                .font : font,
                .foregroundColor : textColor,
                .link : URL(string: link) ?? "",
                .underlineColor : UIColor.clear
            ]
            return rtn
        }
        
        let mtbStr = NSMutableAttributedString()
        
        let t0 = NSAttributedString(string: HLLanguage.UserProtocolPart1.localized(), attributes: attributes("", fontBlackColor))
        let link0 = NSAttributedString(string: HLLanguage.UserProtocolPart2.localized(), attributes: attributes("https://baidu.com", fontBlueColor))
        let t1 = NSAttributedString(string: HLLanguage.UserProtocolPart3.localized(), attributes: attributes("", fontBlackColor))
        
        [t0,link0,t1].forEach{mtbStr.append($0)}
        
        self.textNode.do{
            $0.maximumNumberOfLines = 0
            $0.attributedText = mtbStr
            $0.frame = CGRect(origin: CGPoint(x: 53, y: 1000), size: .zero)
        }
    }
    
    @objc func changeAgreeStatus(){
        let notAgreeImg = UIImage(bundleImageName: "loginNotAgree")
        let agreeImg = UIImage(bundleImageName: "loginAgree")
        
        let shouldAgree = imgNode.imageNode.image == notAgreeImg
        
        imgNode.imageNode.image = shouldAgree ? agreeImg : notAgreeImg
        onAgreeOrNot(shouldAgree)
    }
    
    @objc func clickAgree(){
        AccountRepo.getAgreementService{[weak closestViewController] url in
            let vc = WebController(url: url)
            if closestViewController != nil{
                closestViewController?.navigationController?.pushViewController(vc, animated: true)
            }else{
                HUD.currentVC()?.navigationController?.pushViewController(vc, animated: true)
            }
        }
            
    }
}

