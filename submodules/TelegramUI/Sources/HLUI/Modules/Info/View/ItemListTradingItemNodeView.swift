//
//  ItemListTradingItemNodeView.swift
//  TelegramUI
//
//  Created by 黄国坚 on 2020/5/11.
//  Copyright © 2020 Telegram. All rights reserved.
//

import UIKit
import TelegramCore

import Then
import Model
import Repo
import Language
import UI
import HL
import Extension
import Account
import RxSwift

public enum ItemListTradingItemType: Then, Equatable{
    ///申请
    case apply
    ///再次申请
    case again
    ///续费
    case renewal
    ///已开通 lumpSum:是否一次性付清
    case success(lumpSum: Bool)
    ///审核中
    case review
}

public class ItemListTradingItemNodeView: UIView{
    
    ///小标题 行情实时回馈 | 留长交易体验 | 多种分佣模式
    @IBOutlet weak var headingsLb: UILabel!
    ///查看申请失败原因的按钮
    @IBOutlet weak var checkFailEasonBtn: UIButton!
    
    ///按时扣费的superView
    @IBOutlet weak var rentSuperView: UIStackView!
    ///押金label
    @IBOutlet weak var depositLb: UILabel!
    ///下轮扣费日期
    @IBOutlet weak var deadlineLb: UILabel!
    
    ///“查看”“续费”“再次申请”按钮
    @IBOutlet weak var handelBtn: UIButton!
    
    public var chatId: String = ""
    ///点击开通的回调
    public var onApply: ((ItemListTradingItemType)->())?
    ///开通信息
    public var detail: BiluM.Group.Detail!{
        didSet{
            guard detail != nil else {return}
            updateUI()
        }
    }
    
    private let repo: BiLuRepo = BiLuRepo()
    private let disposeBag: DisposeBag = DisposeBag()
    private var tradingType: ItemListTradingItemType?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        setBind()
    }
}

extension ItemListTradingItemNodeView{
    
    private func setBind(){
        
        //查看申请失败原因
        checkFailEasonBtn.rx.tap.subscribe(onNext: {[weak self] in
            guard let self = self,
                let containerView = self.asdk_associatedViewController?.view else {return}
            
            let contentView = TradingFailSeasonView.loadFromNib().then{
                $0.frame = CGRect(x: (containerView.bounds.size.width - $0.bounds.width)/2,
                                  y: (containerView.bounds.size.height - $0.bounds.height)/2,
                                  width: $0.bounds.width,
                                  height: $0.bounds.height)
                $0.reasonLabel.text = HLLanguage.ReasonsForRefusal.str + "：" + (self.detail.reason ?? "")
            }
            
            let popView = PopView(containerView: containerView,
                                  contentView: contentView)
                .backColor(UIColor.black.withAlphaComponent(0.7))
                .dismissible(true)
                .interactive(true)
                .penetraable(false)
            popView.display()
        }).disposed(by: disposeBag)
        
        //申请
        handelBtn.rx.tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else {return}
                guard let b = self.onApply else {return}
//                if !HLAccountManager.walletIsLogined{
//                    b(self.detail.status == 2 ? .renewal : .apply)
//                }else{
                    if self.detail.status == 2{
                        self.popRenewView()
                    }else if let type = self.tradingType{
                        b(type)
                    }
                //}
            }).disposed(by: disposeBag)
    }
    
    ///更新UI数据
    private func updateUI(){
        
        ///开通状态
        tradingType = {() -> ItemListTradingItemType in
            
            switch detail.status!{
            case 0, 3, 4: return .apply
            case 1:
                let lumpSum = detail.type == 1
                return .success(lumpSum: lumpSum)
            case 2: return .renewal
            case 5:
                if detail.applyStatus == 3{
                    return .again
                }
                return .review
            default:
                return .apply
            }
        }()
        .then(updateLayout)
        .then(updateBtnStyle)
        
        //如果是周期付费
        if let depositAmount = detail.depositAmount,
            let depositCoinName = detail.depositCoinName,
            let time = detail.nextPayTime {
            depositLb.text = Trading.apply.Deposit.str + depositAmount + " " + depositCoinName
            deadlineLb.text = "下轮扣费日期：" + Date(timeIntervalSince1970: time / 1000 ).jy.toString(dateFormat: .yyyy_MM_dd)
        }
        
    }
    
    ///更新UI显示
    private func updateLayout(_ s: ItemListTradingItemType){
        
        headingsLb.isHidden = {
            let ary: [ItemListTradingItemType] = [.apply, .renewal, .review, .success(lumpSum: true)]
            return !ary.contains(s)
        }()
        checkFailEasonBtn.isHidden = (s != .again)
        rentSuperView.isHidden = (s != .success(lumpSum: false))
    }
    ///更新按钮状态的显示
    private func updateBtnStyle(_ s: ItemListTradingItemType){
        
        let (title, bgColor, enable): (String, UIColor, Bool) = {
            
            var title: String
            var enable: Bool = true
            var bgColor: UIColor = UIColor.hex(.k2080FF)

            switch s {
            case .apply:
                title = Trading.apply.check.str
            case .again:
                title = Trading.apply.again.str
            case .renewal:
                title = Trading.apply.renewal.str
            case .success:
                title = Trading.apply.opened.str
            case .review:
                title = Trading.apply.review.str
                enable = false
                bgColor = UIColor.hex(.kGray)
            }
            return (title, bgColor, enable)
        }()
        handelBtn.do{
            $0.setTitle(title, for: .normal)
            $0.isEnabled = enable
            $0.backgroundColor = bgColor
            $0.layer.shadowColor = bgColor.cgColor
        }
    }
    ///弹出续费弹窗
    private func popRenewView(){
        
        let containerView = self.asdk_associatedViewController!.view!
        PopViewUtil.pwdIntput(containerView: containerView, customContentView: { contentView in
            
            contentView.titleL.text = HLLanguage.TransactionPassword.str
            contentView.confirmBtn.do{
                $0.createGradient([UIColor.hex(.k56B8FF),UIColor.hex(.k238AFF)], 1)
                $0.createGradient([UIColor.hex(.kGray),UIColor.hex(.kGray)], 1,.disabled)
            }
            
            _ = { () -> PopTradApplyView in
                return Bundle.getAppBundle().loadNibNamed("PopTradApplyView", owner: nil, options: nil)![1] as! PopTradApplyView
                }()
                .then({
                    $0.paymentLb.text = self.detail.payAmount! + " " + self.detail.payCoinName!
                })
                .adhere(toSuperView: contentView.midView)
                .layout(snapKitMaker: {
                    $0.edges.equalToSuperview()
                })
            
        }, onConfirm: {[weak self] pwd in
            print("续费的交易密码 \(pwd)")
            guard let self = self else {return}
            self.repo.renew(groupTelegramId: self.chatId, payPassword: pwd).value({[weak self] in
                if $0.pwdErrorTimes == nil || $0.pwdErrorTotalTimes == nil{
                    HUD.flash(.label("续费成功"), completion: { _ in
                        guard let nv = self?.asdk_associatedViewController?.navigationController,
                            let chatVC = nv.viewControllers.filter({
                                let vcStr: String = NSStringFromClass($0.classForCoder)
                                return vcStr.contains("ChatController")
                            }).last else {return}
                        nv.popToViewController(chatVC, animated: true)
                    })
                }else {
                    HLAccountManager.shareAccount.pwdErrorTimes = $0.pwdErrorTimes!
                    HLAccountManager.shareAccount.pwdErrorTotalTimes =
                        $0.pwdErrorTotalTimes
                    
                    HUD.flash(.label(Trading.IncorrectTransactionPassword.str))
                }
            }).netWorkState({
                switch $0 {
                case .loading:
                    HUD.show(.systemActivity)
                case .success:
                    break
                case .error(let er):
                    HUD.flash(.label(er.msg))
                }
            }).load(self.disposeBag)
        })
    }
    
}

//MARK: - Then拓展
extension Then where Self: Any {
    
    /// Makes it available to set properties with closures just after initializing.
    ///
    ///     let label = UILabel().then {
    ///       $0.textAlignment = .center
    ///       $0.textColor = UIColor.black
    ///       $0.text = "Hello, World!"
    ///     }
    public func then(_ block: (Self) throws -> Void) rethrows -> Self {
        try block(self)
        return self
    }
    
}
