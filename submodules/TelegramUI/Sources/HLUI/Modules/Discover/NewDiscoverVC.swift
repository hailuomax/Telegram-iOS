//
//  NewDiscoverVC.swift
//  TelegramUI#shared
//
//  Created by fan on 2020/9/30.
//

import UIKit
import HLBase
import Config
import ViewModel
import Model
import UI
import Extension
import HL
import RxCocoa
import RxSwift
import RxDataSources
import Language
import TelegramUIPreferences
import Account
import Display
import PresentationDataUtils
import AccountContext

let kSectionEdge = UIEdgeInsets(top: 6, left: 15, bottom: 6, right: 15)

let kSectionWidth = kScreenWidth - kSectionEdge.left - kSectionEdge.right

enum DiscoverActionType {
    /// 跳转网页 或者机器人
    case resolveURL(url: String)
    /// 应用内跳转
    case native(type: Model.Discover.RefCode, item: Model.Discover.Item)
}

class NewDiscoverVC: HLBaseVC<NewDiscoverView> {
    
    lazy var headerBgView : UIView = UIView()
    
    var gradientLayer = CAGradientLayer()
    
    lazy var viewModel = ViewModel.Discover()
    
    lazy var dataSource: RxCollectionViewSectionedReloadDataSource<Model.Discover.Section> = createDataSources()
        
    let needUpdateBage = PublishSubject<Void>()
    
    private var overlayStatusController: ViewController?
        
    override init(context: TGAccountContext?, presentationData: PD? = nil) {
        super.init(context: context, presentationData: presentationData)
        
        let icon = UIImage(bundleImageName: "Chat List/Tabs/IconFound")
        self.tabBarItem.image = icon
        self.tabBarItem.selectedImage = icon
        self.tabBarItem.title = HLLanguage.TabBar.Discover.str
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        setUI()
        bindUI()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        needUpdateBage.onNext(())
//        self.updateTheme()
//        if needShowGuide == true {
//            showGuide()
//        }
        self.tabBarItem.title = HLLanguage.TabBar.Discover.localized()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissLoading()
    }
    
    func setUI() {
        let _ = updateExperimentalUISettingsInteractively(accountManager: self.context!.sharedContext.accountManager, { settings in
            var settings = settings
            settings.keepChatNavigationStack = true
            return settings
        }).start()
        
        let headerHeight : CGFloat = 150 + (isNotch ? 20 : 0)
        self.view.backgroundColor = UIColor(hexString: "F4F5F7")
        self.contentView.backgroundColor = .clear
        headerBgView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: headerHeight)
        self.view.insertSubview(headerBgView, at: 0)
        self.contentView.collectionView.delegate = self
        
        DispatchQueue.main.async {
            self.contentView.layout(snapKitMaker: {
                $0.top.equalTo(0)
                $0.left.equalToSuperview()
                $0.width.equalTo(kScreenWidth)
                $0.bottom.equalTo(-TabBarHeight)
            })
            self.contentView.layoutIfNeeded()
        }
        
        self.displayNavigationBar = false
        if #available(iOS 11.0, *) {
            self.contentView.collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        let layer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: kScreenWidth/2,y: 0), radius: 450, startAngle: 0, endAngle: .pi, clockwise: true)
        layer.path = circularPath.cgPath
        gradientLayer.mask = layer
        gradientLayer.frame = CGRect(x: 0, y: headerHeight - 450, width: kScreenWidth, height: 450)
        gradientLayer.colors = [UIColor.hexInt32(0x0B9CFF).cgColor, UIColor.hexInt32(0x0A59FF).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        headerBgView.layer.addSublayer(gradientLayer)
    }
    
    func bindUI() {
        let output = viewModel.transform(input: Discover.Input(refresh: contentView.collectionView.rx.onRefresh, updateBage: needUpdateBage))
        
        output.isRefreshing.bind(to: contentView.collectionView.rx.isRefreshing).disposed(by: disposeBag)
        
        output.sections.drive( contentView.collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        contentView.collectionView.rx.modelSelected(Model.Discover.Section.Item.self)
            .subscribe(onNext: {[weak self] row in
                guard let self = self else {return}
                switch row {
                case .bot(let item),
                     .hot(let item):
                    self.selectedItem(item)
                default:
                    break
                }
            }).disposed(by: disposeBag)
        
        DispatchQueue.main.async {
            self.contentView.collectionView.jy.startRefresh()
        }
        
        output.hasNewMessage.drive(onNext: {[weak self] in
            self?.tabBarItem.badgeValue = $0 ? "0" : ""
            guard let self = self else {return}
            let sectionModels = self.dataSource.sectionModels
            guard let section = sectionModels.enumerated().first(where: {$0.element.header == "热门"})?.offset else {return}
            let items : [String] = [Model.Discover.RefCode.notice.rawValue, Model.Discover.RefCode.welfareBot.rawValue]
            //要刷新的IndexPath
            let rows = sectionModels[section].items.enumerated().filter {
                if case .hot(let item) = $0.element {
                    return items.contains(item.refCode ?? "")
                }else {
                    return false
                }
            }
            .map{$0.offset}
            .map{IndexPath(row: $0, section: section)}
            self.contentView.collectionView.reloadItems(at: rows)

        }).disposed(by: disposeBag)
        
    }
    
    
    //MARK: Cell and SectionHeader
    func createDataSources() -> RxCollectionViewSectionedReloadDataSource<Model.Discover.Section> {
        
        return RxCollectionViewSectionedReloadDataSource<Model.Discover.Section>.init(configureCell: { (ds, collectionView, indexPath, section) -> UICollectionViewCell in
            switch section {
            case .banner(let list):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverBannerCell", for: indexPath) as! DiscoverBannerCell
                cell.setModel(list: list)
                cell.gradientLayerDidChange.subscribe(onNext: {[weak self] colors in
                    self?.gradientLayer.colors = colors
                }).disposed(by: cell.disposeBag)
                // 处理特殊情况
                cell.didSeletedItem.map { (item) -> Model.Discover.Item in
                    var model = item
                    if model.linkType == 6, model.link == "http://\(Scheme.i7_app)/jumpExchange" {
                        model.refCode = Model.Discover.RefCode.exchangeSquare.rawValue
                    }
                    return model
                }.subscribe(onNext: {[weak self] item in
                    self?.selectedItem(item)
                }).disposed(by: cell.disposeBag)
                
                return cell
                
            case .sysMessage(let list):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverNoticeCell", for: indexPath) as! DiscoverNoticeCell
                cell.setList(list: list)
                cell.didSelectedItem.subscribe(onNext: {[weak self] item in
                    guard let self = self else {return}
                    let vc = SystemMessageDetailsVC(model: item, contenxt: self.context, presentationData: self.presentationData)
                    self.navigationController?.pushViewController(vc, animated: true)
                }).disposed(by: cell.cellBag)
                return cell
                
            case .hot(let item):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverItemCollectionCell", for: indexPath) as! DiscoverItemCollectionCell
                cell.setItem(item: item)
                return cell
                
            case .recommend(let list):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverRecommendCell", for: indexPath) as! DiscoverRecommendCell
                cell.listData.onNext(list)
                cell.didSelectedItem.subscribe(onNext: {[weak self] item in
                    self?.selectedItem(item)
                }).disposed(by: cell.disposeBag)
                return cell
                
            case .bot(let item):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverItemCollectionCell", for: indexPath) as! DiscoverItemCollectionCell
                cell.setItem(item: item)
                return cell
            }
        }, configureSupplementaryView: { (ds, collectionView, kind, indexPath) -> UICollectionReusableView in
            if kind == UICollectionView.elementKindSectionHeader {
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! DiscoverSectionHeaderView
                switch ds[indexPath] {
                case .sysMessage, .banner:
                    break
                case .bot , .hot:
                    view.moreButton.isHidden = true
                    view.titleLabel.text = ds[indexPath.section].header
                default:
                    view.moreButton.isHidden = false
                    view.titleLabel.text = ds[indexPath.section].header
                    // 查看更多推荐群
                    view.moreButton.rx.controlEvent(.touchUpInside)
                        .subscribe(onNext:{[weak self] _ in
                            guard let self = self else { return }
                            let groupVM = DiscoverGroupVM()
                            let groupVC = DiscoverGroupVC(context: self.context,viewModel: groupVM, selectedTitle:  ds[indexPath.section].header)
                            self.navigationController?.pushViewController(groupVC, animated: true)
                        }).disposed(by: view.disposeBag)
                }
                return view
            }else {
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
                return view
            }
        })
    }

    func selectedItem(_ item: Model.Discover.Item) {
        //跳转类型 1-跳转机器人页面 2-加入电报群聊 3-跳转频道会话 4,不可点击 5,网页跳转 6,App内跳转\
        var type : DiscoverActionType?
        switch item.linkType {
        case 1, 2, 3, 5:
            type = DiscoverActionType.resolveURL(url: item.link ?? "")
        case 6:
            guard let refCode = Model.Discover.RefCode(rawValue: item.refCode ?? "") else {return}
            type = DiscoverActionType.native(type: refCode, item: item)
        default:break
        }
        
        guard let actionType = type else {return}
        self.action(type: actionType)
    }
    
    //MARK: 跳转
    func action(type: DiscoverActionType){
        switch type {
        case .resolveURL(let url):
            self.resolveURL(url)
        case .native(let type, let item):
            switch type {
            case .exchangeSquare:
                self.validate {[weak self] in
                    guard let self = self else {return}
                    let squareVC = ExchangeSquareVC(context: self.context)
                    self.navigationController?.pushViewController(squareVC, animated: true)
                }
            case .coinRoadExchange:
                self.validate {[weak self] in
                    guard let self = self , let link = item.link, let url = URL(string: link + "?token=\(HLAccountManager.shareAccount.token ?? "")") else {
                        HUD.flashOnTopVC(.label("地址无效！"))
                        return
                    }
                    app.openUrl(url: url)
                }
            case .clcLockAndMining:
                let activityVC: MiningActivitiesAdvertisingVC = MiningActivitiesAdvertisingVC(presentationData: self.presentationData)
                self.navigationController?.pushViewController(activityVC, animated: true)
                
            case .notice:
                let sysMessageVC = SystemMessagesVC(context: self.context!)
                self.navigationController?.pushViewController(sysMessageVC, animated: true)
                
            case .entrust:
                if HLAccountManager.biLuToken.isEmpty {
                    let logoinVC = TransactionLoginVC(context:self.context)
                    logoinVC.successBlock = { [weak self] in
                        guard let self = self else { return }
                        self.navigationController?.popViewController(animated: true)
                    }
                    HLAccountManager.validateAccountAndcheckPwdSetting((self, logoinVC), context: self.context!)
                } else {
                    let entrustAllVC = EntrustAllVC(symbol: "",context:self.context)
                    HLAccountManager.validateAccountAndcheckPwdSetting((self, entrustAllVC), context: self.context!)
                }
            default:
                break
            }
        }
    }
    
    func validate(_ continueAction: @escaping ()->()){
        
        if HLAccountManager.walletIsLogined {
            continueAction()
        }else{
            let pushAccountValidationVC : (Bool,Phone)->() = { [weak self] (showPwdView,phone) in
                guard let self = self else {return}
                let vc = AccountValidationVC(phone:phone, context: self.context!,showPwdView: showPwdView, onValidateSuccess: {
                    //手势设置页面设置好手势密保，或者点击跳过，会有此回调
                    continueAction()
                })
                self.navigationController?.pushViewController(vc, animated: true)
            }
            let presentationData = self.context!.sharedContext.currentPresentationData.with({ $0 })
            
            AssetVerificationViewController.show(presentationData: presentationData, currentVC: self, onPushAccountLockVC: {[weak self] in
                guard let self = self else {return}
                let disableVC = AccountLockVC(context: self.context!, title: $0)
                self.navigationController?.pushViewController(disableVC, animated: true)
                
                }, onPushAccountValidationVC: {
                    pushAccountValidationVC($0,$1)
            }, onPushBindExceptionVC: {[weak self] in
                guard let self = self else {return}
                let exceptionVM = BindExceptionVM(oldPhoneCode: $0, oldTelephone: $1, payPwdStatus: $2, onValidateSuccess: {})
                
                let exceptionVC = $0 == "1" ? BindExceptionPswVC(context: self.context, viewModel: exceptionVM) : BindExceptionCaptchaVC(context: self.context, viewModel: exceptionVM)
                self.navigationController?.pushViewController(exceptionVC, animated: true)
            })
        }
    }
    
    func resolveURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        showLoading()
        app.openUrl(url: url)
    }
    
    func showLoading() {
        overlayStatusController = OverlayStatusController(theme: self.presentationData.theme,  type: .loading(cancelled: nil))
        self.present(overlayStatusController!, in: .window(.root))
    }
    
    func dismissLoading() {
        overlayStatusController?.dismiss()
    }
}
//MARK: --CollectionView样式
extension NewDiscoverVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch dataSource[indexPath] {
        case .banner:
            return CGSize(width: kScreenWidth, height: 130)
        case .bot, .hot:
            return CGSize(width: kSectionWidth / 4, height: 76)
        case .sysMessage:
            return CGSize(width: kSectionWidth, height: 38)
        case .recommend:
            return CGSize(width: kSectionWidth, height: 117)
        }
    
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath.init(row: 0, section: section)
        switch dataSource[indexPath] {
        case .banner, .sysMessage:
            return CGSize.zero
        default:
            return CGSize(width: kSectionWidth, height: 50 + kSectionEdge.top)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let indexPath = IndexPath.init(row: 0, section: section)
        switch dataSource[indexPath] {
        case .banner, .sysMessage:
            return CGSize.zero
        default:
            return CGSize(width: kSectionWidth, height: (section == dataSource.sectionModels.count - 1 ? 40 : 10) + kSectionEdge.bottom )
        }
    }
    
    
    //在同一个Section中相邻两行之间的间隙
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    //在同一个Section中相邻两个item之间的间隙
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    //每个分区的间隙
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let indexPath = IndexPath.init(row: 0, section: section)
        switch dataSource[indexPath] {
        case .banner, .sysMessage:
            return UIEdgeInsets(top: 5, left: kSectionEdge.left, bottom: 5, right: kSectionEdge.right)
        default:
            return UIEdgeInsets(top: 0, left: kSectionEdge.left, bottom: 0, right: kSectionEdge.right)
        }
        
    }
        
}

extension NewDiscoverVC {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 && scrollView.contentOffset.y <= headerBgView.frame.height {
            headerBgView.frame = CGRect(x: 0, y: -scrollView.contentOffset.y, width: headerBgView.frame.width, height: headerBgView.frame.height)
        }
        
        contentView.navigationBgView.backgroundColor = UIColor.hex(ColorEnum.kBlue, alpha: scrollView.contentOffset.y / NavBarHeight)
    }
}


class NewDiscoverView: BaseContentViewType{
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var navigationBgView: UIView!
    @IBOutlet var navigationHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.registerNibCell(DiscoverBannerCell.self, forCellWithReuseIdentifier: "DiscoverBannerCell")
        collectionView.registerNibCell(DiscoverRecommendCell.self, forCellWithReuseIdentifier: "DiscoverRecommendCell")
        collectionView.registerNibCell(DiscoverItemCollectionCell.self, forCellWithReuseIdentifier: "DiscoverItemCollectionCell")
        collectionView.registerNibCell(DiscoverNoticeCell.self, forCellWithReuseIdentifier: "DiscoverNoticeCell")
        
        collectionView.register(DiscoverSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        collectionView.register(DiscoverSectionFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
        collectionView.backgroundColor = .clear
        navigationHeight.constant = NavBarHeight
        navigationBgView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
    }
    
}

