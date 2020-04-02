//
//  HUD.swift
//  PKHUD
//
//  Created by Eugene Tartakovsky on 29/01/16.
//  Copyright © 2016 Eugene Tartakovsky, NSExceptional. All rights reserved.
//  Licensed under the MIT license.
//

import UIKit
import HL

public enum HUDContentType {
    case success
    case error
    case progress
    case image(UIImage?)
    case rotatingImage(UIImage?)

    case labeledSuccess(title: String?, subtitle: String?)
    case labeledError(title: String?, subtitle: String?)
    case labeledProgress(title: String?, subtitle: String?)
    case labeledImage(image: UIImage?, title: String?, subtitle: String?)
    case labeledRotatingImage(image: UIImage?, title: String?, subtitle: String?)

    case label(String?)
    case systemActivity
    case customView(view: UIView)
}

public final class HUD {

    // MARK: Properties
    public static var dimsBackground: Bool {
        get { return PKHUD.sharedHUD.dimsBackground }
        set { PKHUD.sharedHUD.dimsBackground = newValue }
    }

    public static var allowsInteraction: Bool {
        get { return PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled  }
        set { PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = newValue }
    }
    
//    public static var isMarginNavigationBar: Bool {
//        get { return PKHUD.sharedHUD.isMarginNavigationBar  }
//        set { PKHUD.sharedHUD.isMarginNavigationBar = newValue }
//    }
//    
//    public static var isMarginTabbar: Bool {
//        get { return PKHUD.sharedHUD.isMarginTabbar  }
//        set { PKHUD.sharedHUD.isMarginTabbar = newValue }
//    }

    public static var leadingMargin: CGFloat {
        get { return PKHUD.sharedHUD.leadingMargin  }
        set { PKHUD.sharedHUD.leadingMargin = newValue }
    }

    public static var trailingMargin: CGFloat {
        get { return PKHUD.sharedHUD.trailingMargin  }
        set { PKHUD.sharedHUD.trailingMargin = newValue }
    }

    public static var isVisible: Bool { return PKHUD.sharedHUD.isVisible }

    // MARK: Public methods, PKHUD based
    public static func show(_ content: HUDContentType, onView view: UIView? = nil,dismiss dismissBackground: Bool = true, marginTop isMarginNavigationBar: Bool = false,marginBottom isMarginTabbar: Bool = false) {
        PKHUD.sharedHUD.contentView = contentView(content)
        PKHUD.sharedHUD.show(onView: view,dismiss:dismissBackground,marginTop:isMarginNavigationBar,marginBottom:isMarginTabbar)
    }

    public static func hide(_ completion: ((Bool) -> Void)? = nil) {
        PKHUD.sharedHUD.hide(animated: false, completion: completion)
    }

    public static func hide(animated: Bool, completion: ((Bool) -> Void)? = nil) {
        PKHUD.sharedHUD.hide(animated: animated, completion: completion)
    }

    public static func hide(afterDelay delay: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        PKHUD.sharedHUD.hide(afterDelay: delay, completion: completion)
    }
    
    public static func retryShow(animated: Bool,tips : String? = nil, retryBlock: (() -> Void)? = nil) {
        PKHUD.sharedHUD.retryShow(animated,tips :tips, retryBlock: retryBlock)
    }


    public static func flash(_ content: HUDContentType, onView view: UIView? = nil, delay: TimeInterval = 1, completion: ((Bool) -> Void)? = nil) {
        HUD.show(content, onView: view)
        HUD.hide(afterDelay: delay, completion: completion)
    }
    
    public static func flashOnTopVC(_ content: HUDContentType,after: TimeInterval = 0, delay: TimeInterval? = 1.5, completion: ((Bool) -> Void)? = nil) {
        if after > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + after) {
                HUD.show(content, onView: HUD.currentVC().view)
                HUD.hide(afterDelay: delay ?? 1.5, completion: completion)
            }
        }else{
            HUD.show(content, onView: HUD.currentVC().view)
            HUD.hide(afterDelay: delay ?? 1.5, completion: completion)
        }
    }
    
    public static func showOnTopVC(_ content: HUDContentType = .systemActivity) {
        PKHUD.sharedHUD.contentView = contentView(content)
        PKHUD.sharedHUD.show(onView: HUD.currentVC().view)
    }

    
    static func currentVC(_ viewController : UIViewController? = nil) -> UIViewController{
        
        var rootVC = viewController
        if rootVC == nil,let windowVC = app.mainWindow?.viewController as? TelegramRootController{
            rootVC = windowVC
        }
        
        if let presentedVC = rootVC?.presentedViewController {
            return HUD.currentVC(presentedVC)
        }else if rootVC is UITabBarController,let tabBarVC = rootVC as? UITabBarController{
            return HUD.currentVC(tabBarVC.selectedViewController)
        }else if rootVC is UINavigationController,let navVC = rootVC as? UINavigationController{
            return HUD.currentVC(navVC.visibleViewController)
        }else{
            return rootVC ?? UIViewController()
        }
    }
    
    // MARK: Keyboard Methods
    public static func registerForKeyboardNotifications() {
        PKHUD.sharedHUD.registerForKeyboardNotifications()
    }
    
    public static func deregisterFromKeyboardNotifications() {
        PKHUD.sharedHUD.deregisterFromKeyboardNotifications()
    }

    // MARK: Private methods
    fileprivate static func contentView(_ content: HUDContentType) -> UIView {
        switch content {
        case .success:
            return PKHUDSuccessView()
        case .error:
            return PKHUDErrorView()
        case .progress:
            return PKHUDProgressView()
        case let .image(image):
            return PKHUDSquareBaseView(image: image)
        case let .rotatingImage(image):
            return PKHUDRotatingImageView(image: image)

        case let .labeledSuccess(title, subtitle):
            return PKHUDSuccessView(title: title, subtitle: subtitle)
        case let .labeledError(title, subtitle):
            return PKHUDErrorView(title: title, subtitle: subtitle)
        case let .labeledProgress(title, subtitle):
            return PKHUDProgressView(title: title, subtitle: subtitle)
        case let .labeledImage(image, title, subtitle):
            return PKHUDSquareBaseView(image: image, title: title, subtitle: subtitle)
        case let .labeledRotatingImage(image, title, subtitle):
            return PKHUDRotatingImageView(image: image, title: title, subtitle: subtitle)

        case let .label(text):
            return PKHUDTextView(text: text)
        case .systemActivity:
            return PKHUDSystemActivityIndicatorView()
        case let .customView(view):
            return view
        }
    }
}
