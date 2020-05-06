//
//  ChatMessageBubbleContentNode-Extension.swift
//  TelegramUI#shared
//
//  Created by lemon on 2020/5/6.
//

import Foundation
import UI
import AccountContext
import Model
import Display
import ViewModel

extension ChatMessageBubbleContentNode {
    func assetVerification(currentVC: ChatController) {
        let pushAccountValidationVC : (Bool,Phone)->() = {  (showPwdView,phone) in
            let vc = AccountValidationVC(context: currentVC.context ,showPwdView: showPwdView, onValidateSuccess: {[weak currentVC] in
                currentVC?.navigationController?.popViewController(animated: true)
            })
            currentVC.navigationController?.pushViewController(vc, animated: true)
        }
        
        let pushControllerImpl: (ViewController) -> () = { vc in
            currentVC.navigationController?.pushViewController(vc, animated: true)
        }
        
        //没有token，需要跳转到用户验证的vc
        let context = currentVC.context
        
        AssetVerificationViewController.show(context: context, currentVC: currentVC, onPushAccountLockVC: {
            let disableVC = AccountLockVC(context: context, title: $0)
            pushControllerImpl(disableVC)
        }, onPushAccountValidationVC: {
            pushAccountValidationVC($0,$1)
        }, onPushBindExceptionVC: {
            let exceptionVM = BindExceptionVM(oldPhoneCode: $0, oldTelephone: $1, payPwdStatus: $2, onValidateSuccess: {})
            let exceptionVC = $0 == "1" ? BindExceptionPswVC(context: context, viewModel: exceptionVM) : BindExceptionCaptchaVC(context: context, viewModel: exceptionVM)
            pushControllerImpl(exceptionVC)
        })
    }
}


