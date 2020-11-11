//
//  ChatMessageBubbleContentNode-Extension.swift
//  TelegramUI#shared
//
//  Created by fan on 2020/5/6.
//

import Foundation
import UI
import AccountContext
import Model
import Display
import ViewModel
import TelegramPresentationData

extension ChatMessageBubbleContentNode {
    func assetVerification(currentVC: ChatController) {
        
        //没有token，需要跳转到用户验证的vc
        let context = currentVC.context
        let presentationData = context.sharedContext.currentPresentationData.with({ $0 })
        
        let pushAccountValidationVC : (Bool,Phone,Bool)->() = {  (showPwdView,phone,canLoginWithPwd) in
//            let vc = AccountValidationVC(phone:phone, context: currentVC.context ,showPwdView: showPwdView, onValidateSuccess: {[weak currentVC] in
//                currentVC?.navigationController?.popViewController(animated: true)
//            })
            let vc = AccountValidationVC.create(presentationData: presentationData, showPwdView: showPwdView, phone: phone, canLoginWithPwd: canLoginWithPwd) { [weak currentVC] in
                currentVC?.navigationController?.popViewController(animated: true)
            }
            currentVC.navigationController?.pushViewController(vc, animated: true)
        }
        
        let pushControllerImpl: (ViewController) -> () = { vc in
            currentVC.navigationController?.pushViewController(vc, animated: true)
        }
        
        
        AssetVerificationViewController.show(presentationData: presentationData, currentVC: currentVC, onPushAccountLockVC: {
            let disableVC = AccountLockVC(presentationData: presentationData, title: $0)
            pushControllerImpl(disableVC)
        }, onPushAccountValidationVC: {
            pushAccountValidationVC($0,$1,$2)
        }, onPushBindExceptionVC: {
            let exceptionVM = BindExceptionVM(oldPhoneCode: $0, oldTelephone: $1, payPwdStatus: $2, onValidateSuccess: {})
            let exceptionVC = $0 == "1" ? BindExceptionPswVC(presentationData: presentationData, viewModel: exceptionVM) : BindExceptionCaptchaVC(presentationData: presentationData, viewModel: exceptionVM)
            pushControllerImpl(exceptionVC)
        })
    }
}


