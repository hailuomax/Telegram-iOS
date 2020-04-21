//
//  DiscoverVC.swift
//  TelegramUI
//
//  Created by tion126 on 2019/10/14.
//  Copyright © 2019 Telegram. All rights reserved.
//

import UIKit
import TelegramCore
import AsyncDisplayKit
import TelegramUIPreferences
import TelegramPresentationData
import TelegramPermissionsUI
import TelegramPermissions
import Display
import DeviceAccess
import SwiftSignalKit
import CoreLocation

import HL
import UI
import Account
import AccountContext
import Repo
import HLBase
import Config
import Model
import ViewModel
import Language
import Extension
import Theme

private let kDiscoverSectionFooter = "k\(DiscoverSectionFooter.self)"
private let kDiscoverSectionHeader = "k\(DiscoverSectionHeader.self)"
private let kDiscoverItemCell      = "k\(DiscoverItemCell.self)"

private func resolveURL(_ model : DiscoverListItemModel?){
    guard let link = model?.link , model?.linkType != 4 ,var url = URL(string: link) else {return}
    url = URL(string:spliceWebUrl(link))!
    app.openUrl(url: url)
}

/*
 * h5 链接拼接多语言
 */
private func spliceWebUrl(_ url : String) -> String{
    guard url.isEmpty == false else { return url}
    var link = url
    let text = url.suffix(1)
    if text != "?"{
      link += "?"
    }
    link += "\("lang=")\(APPConfig.locale.rawValue)"
    return link
}

class DiscoverVC: HLBaseVC<DiscoverView> {
    
    private var viewModel: DiscoverVM!
    
    private lazy var locationManager = CLLocationManager()
    /*
     * 修改记录
     * 2020/3/24 修改tabBar发现图片
     * 去掉 .withRenderingMode(.alwaysOriginal)
     */
    override init(context: AccountContext?, presentationData: PresentationData? = nil) {
        super.init(context: context, presentationData: presentationData)
        
//        let icon = UIImage(bundleImageName: "Chat List/Tabs/IconRedpacket")?.withRenderingMode(.alwaysOriginal)
        let icon = UIImage(bundleImageName: "Chat List/Tabs/IconFound")
        self.tabBarItem.image = icon
        self.tabBarItem.selectedImage = icon
        
        self.viewModel = DiscoverVM(onUpdateBadge: {[weak self] in
            self?.tabBarItem.badgeValue = $0
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.contentView.titleLabel.text = HLLanguage.Tabbar.Discover.localized()
        self.title = HLLanguage.Tabbar.Discover.localized()
        self.tabBarItem.title = HLLanguage.Tabbar.Discover.localized()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
        
    override func loadView(){
        super.loadView()
        NotificationCenter.default.addObserver(self, selector: #selector(updateTheme), name: Notification.Name(rawValue:"UpdateThemeNofi"), object: nil)
        self.initUI()
        self.setBind()
        
    }
    //ssss
    func initUI(){
        
        self.contentView.layout(snapKitMaker: {
            $0.edges.equalToSuperview()
        })
        
        let _ = updateExperimentalUISettingsInteractively(accountManager: self.context!.sharedContext.accountManager, { settings in
            var settings = settings
            settings.keepChatNavigationStack = true
            return settings
        }).start()
        
        let layer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: kScreenWidth/2,y: 0), radius: 450, startAngle: 0, endAngle: .pi, clockwise: true)
        layer.path = circularPath.cgPath
        let gradientLayer = CAGradientLayer()
        gradientLayer.mask = layer
        gradientLayer.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 450)
        gradientLayer.colors = [UIColor.hexInt32(0x0B9CFF).cgColor, UIColor.hexInt32(0x0A59FF).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        self.contentView.gradientLayer = gradientLayer
        self.contentView.headerBgView.layer.addSublayer(gradientLayer)
        
        self.view.disablesInteractiveTransitionGestureRecognizer = true
        self.contentView.banner.delegate = self
        self.contentView.banner.timeInterval = 3
        self.displayNavigationBar = false
        let themeManager = ThemeManager(self.context!)
        self.contentView.tableView.backgroundColor = themeManager.getPlainBgColor()
        self.contentView.backgroundColor = themeManager.getPlainBgColor()
        self.contentView.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: isNotch ? 83 : 49, right: 0)
        self.contentView.tableView.dataSource = self
        self.contentView.tableView.delegate = self
       
        let name = String(describing: DiscoverItemCell.self)
        let nib = UINib(nibName: name, bundle: Bundle(for: DiscoverItemCell.self))
        self.contentView.tableView.register(nib, forCellReuseIdentifier: kDiscoverItemCell)
        self.contentView.tableView.register(DiscoverSectionHeader.self, forHeaderFooterViewReuseIdentifier: kDiscoverSectionHeader)
         self.contentView.tableView.register(DiscoverSectionFooter.self, forHeaderFooterViewReuseIdentifier: kDiscoverSectionFooter)
    }
    
    func setBind(){
        
        self.contentView.tableView.jy.onRefresh {[weak self] in
            guard let self = self else { return }
            self.viewModel.getDiscoverList()
        }
        
        self.contentView.tableView.jy.startRefresh()
        
        self.viewModel.dataChange.subscribe({ [weak self] (alertStr) in
            guard let self = self else {return}
            self.contentView.tableView.reloadData()
            self.contentView.banner.setUrlsGroup(self.viewModel.bannerDatas.map{$0.linkIcon})
        }).disposed(by: disposeBag)
        
        self.viewModel.isLoading.subscribe(onNext: {[weak self] (isLoading) in
            guard let self = self else {return}
            if !isLoading {
                self.contentView.tableView.jy.stopRefresh()
            }
        }).disposed(by: disposeBag)

    }
    
    @objc func updateTheme() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let themeManager = ThemeManager(self.context!)
            self.contentView.tableView.backgroundColor = themeManager.getPlainBgColor()
            self.contentView.backgroundColor = themeManager.getPlainBgColor()
            self.contentView.tableView.reloadData()
        }
    }
    ///验证y
    @objc func validate(_ continueAction :@escaping ()->()){
        
        if HLAccountManager.shareAccount.token == nil || HLAccountManager.shareAccount.token!.isEmpty {
            
            let pushAccountValidationVC : (Bool,Phone)->() = { [weak self] (showPwdView,phone) in
                guard let self = self else {return}
                let vc = AccountValidationVC(context: self.context!,showPwdView: showPwdView, onValidateSuccess: {
                    //手势设置页面设置好手势密保，或者点击跳过，会有此回调
                    continueAction()
                })
                self.navigationController?.pushViewController(vc, animated: true)
            }

            AccountRepo.userStatusCheck(context: self.context!, currentVC: self, onPushAccountLockVC: {[weak self] in
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
        }else{
             continueAction()
        }
    }
}


extension DiscoverVC : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.listData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let listData = self.viewModel.listData[section]
        return listData.itemType == 2 ? listData.list?.count ?? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kDiscoverItemCell) as! DiscoverItemCell
        cell.selectionStyle = .gray
        let listData = self.viewModel.listData[indexPath.section]
        if let model = listData.itemType == 2 ?  listData.list?[indexPath.row] : listData {
            cell.iconImageView.setImage(urlString: model.linkIcon ?? model.titleIcon, placeholder:"ic-discover-default")
            cell.titleLabel.text = model.name ?? model.linkName
            ///福利机器人红点显示
            cell.redDot.isHidden = !(model.refCode == "welfareBot" && self.viewModel.welfareBotStatus)
        }
        // 附近的人
        if listData.itemType == 3 {
            cell.iconImageView.image = UIImage(bundleImageName: listData.titleIcon ?? "ic-discover-default")
        }
        ///查看全部
        cell.viewAllLabel.isHidden = listData.itemType != 0
        cell.viewAllLabel.text = HLLanguage.ViewAll.localized()
        cell.contentView.backgroundColor = ThemeManager().getPlainBgColor()
        cell.titleLabel.textColor = ThemeManager().getTextColor()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = self.viewModel.listData[indexPath.section]
        switch model.itemType {
        case 0:
            let groupVM = DiscoverGroupVM()
            groupVM.discoverData = model
            let groupVC = DiscoverGroupVC(context: self.context,viewModel: groupVM)
            self.navigationController?.pushViewController(groupVC, animated: true)
            break
        case 1:
            let detailVM = DiscoverDetailVM()
            detailVM.discoverData = model
            detailVM.type = .channel
            let detailVC = DiscoverDetailVC(context: context, viewModel: detailVM)
            self.navigationController?.pushViewController(detailVC, animated: true)
            break
        case 2:
            
            let rowModel = model.list?[indexPath.row]
            if rowModel?.refCode == "welfareBot" {
                self.viewModel.sendWelfareBotTasks()
                self.contentView.tableView.reloadData()
                self.validate {resolveURL(rowModel)}
                return
            }
            resolveURL(rowModel)
            break
        case 3:
            guard let context = context else { return }
            let _ = (DeviceAccess.authorizationStatus(subject: .location(.tracking))
            |> take(1)
            |> deliverOnMainQueue).start(next: { [weak self] status in
                guard let strongSelf = self  else {
                    return
                }
                let presentPeersNearby = {
                    let controller = NearbyViewController.init(context: context, presentationData: strongSelf.presentationData)
//                    let controller = NearbyViewModel().getViewController(context: context, type: .group)
                    (strongSelf.navigationController as? NavigationController)?.replaceAllButRootController(controller, animated: true, completion: {})
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
                                let _ = (strongSelf.navigationController as? NavigationController)?.popViewController(animated: true)
                            }
                        }
                        (strongSelf.navigationController as? NavigationController)?.pushViewController(controller, completion: { })
                }
            })
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: kDiscoverSectionHeader) as! DiscoverSectionHeader
//        header.contentView.backgroundColor = ColorEnum.kGrayBackground.toColor()
        header.contentView.backgroundColor = ThemeManager().getSectionHeaderColor()
        header.titleLab.textColor = ColorEnum.k999999.toColor()
        header.titleLab.text = self.viewModel.listData[section].name
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let listData = self.viewModel.listData[section]
        return listData.itemType == 2 ? 32 : 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let listData = self.viewModel.listData[section]
        return listData.itemType == 0 ? 103 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: kDiscoverSectionFooter) as! DiscoverSectionFooter
        footer.collectionView.backgroundColor = ThemeManager().getPlainBgColor()
        if let listData = self.viewModel.listData[section].list {
            footer.listData = listData.count >= 5 ? [] + listData.prefix(5) : listData
        }
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}
    
extension DiscoverVC : ZCycleViewProtocol{
    func cycleViewConfigureDefaultCellImageUrl(_ cycleView: ZCycleView, imageView: UIImageView, imageUrl: String?, index: Int) {
        imageView.contentMode     = .scaleToFill
        imageView.backgroundColor = .clear
        imageView.setImage(urlString: imageUrl, placeholder: "bg-banner-placeholder")
    }

    func cycleViewDidSelectedIndex(_ cycleView: ZCycleView, index: Int) {
        let model = self.viewModel.bannerDatas[index]
        if model.linkType == 6,let link = model.link ,link == "http://i7.app/jumpExchange" {
            self.validate {[weak self] in
                guard let self = self else {return}
                //FIXME: 待接入 ExchangeSquareVC
//                let squareVC = ExchangeSquareVC(context: self.context)
//                self.navigationController?.pushViewController(squareVC, animated: true)
            }
            return
        }
        resolveURL(self.viewModel.bannerDatas[index])
    }
    
    func cycleViewDidScroll(_ cycleView: ZCycleView, contentOffset: CGPoint) {
        let x = contentOffset.x
        let width = self.contentView.frame.size.width
        let current = Int(floor(x / width).truncatingRemainder(dividingBy: CGFloat(self.viewModel.bannerDatas.count)))
        let next = current > self.viewModel.bannerDatas.count - 2 ? 0 : current + 1
        let currentColor = self.viewModel.bannerDatas[current].color?.components(separatedBy: "-")
        let nextColor = self.viewModel.bannerDatas[next].color?.components(separatedBy: "-")
        
        let startColor1 = UIColor.hexString(currentColor?.first)
        let endColor1 = UIColor.hexString(nextColor?.first)
        let startColor2 = UIColor.hexString(currentColor?.last)
        let endColor2 = UIColor.hexString(nextColor?.last)
        let coe = x.truncatingRemainder(dividingBy: width) / width

        let mixColor1 = UIColor.mixColor(startColor: startColor1, endColor: endColor1, coe: coe)
        let mixColor2 = UIColor.mixColor(startColor: startColor2, endColor: endColor2, coe: coe)
        self.contentView.gradientLayer.colors = [mixColor1.cgColor,mixColor2.cgColor]
    }
}

class DiscoverView: BaseContentViewType{

    var gradientLayer = CAGradientLayer()
    @IBOutlet weak var headerBgView: UIView!
    @IBOutlet weak var banner: ZCycleView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
}


class DiscoverSectionHeader : UITableViewHeaderFooterView{
    let titleLab : UILabel = {
       let label = UILabel()
        label.text = ""
        label.font = FontEnum.k_pingFangSC_Regular.toFont(13)
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.titleLab)
               self.titleLab.snp.makeConstraints {
                   $0.leading.equalToSuperview().offset(15)
                   $0.centerY.equalToSuperview()
               }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


private let kDiscoverSectionFooterCell = "k\(DiscoverSectionFooterCell.self)"

class DiscoverSectionFooter : UITableViewHeaderFooterView,UICollectionViewDelegate,UICollectionViewDataSource{
    
    var listData = [DiscoverListItemModel]() {
        didSet{
            self.collectionView.reloadData()
        }
    }
    
    let collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 50, height: 103)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = (kScreenWidth - 280)/4
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        view.isScrollEnabled = false
        view.register(DiscoverSectionFooterCell.self, forCellWithReuseIdentifier: kDiscoverSectionFooterCell)
        return view
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kDiscoverSectionFooterCell, for: indexPath) as! DiscoverSectionFooterCell
        cell.contentView.backgroundColor = ThemeManager().getPlainBgColor()
         cell.titleLabel.textColor = ThemeManager().getTextColor()
        cell.model = self.listData[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        resolveURL(self.listData[indexPath.item])
    }
}


class DiscoverSectionFooterCell : UICollectionViewCell{
    
    var model = DiscoverListItemModel() {
        didSet{
            self.iconImage.setImage(urlString: self.model.linkIcon, placeholder: "ic-discover-default")
            self.titleLabel.text = self.model.formatName
        }
    }
    
    let iconImage : UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.backgroundColor = ColorEnum.kF7F7F7.toColor()
        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true
        view.layer.borderColor = ColorEnum.kGray.toColor().cgColor
        view.layer.borderWidth = 0.5
        return view
    }()
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.font = FontEnum.k_pingFangSC_Regular.toFont(12)
        label.textColor = ThemeManager().getTextColor()
        label.textAlignment = .center
        return label
    }()
    
    let typeIconImageView : UIImageView = {
        let view = UIImageView()
        view.image = UIImage(bundleImageName: "ic-discover-arrow")
        view.contentMode = .scaleToFill
        view.layer.cornerRadius = 10.5
        view.layer.masksToBounds = true
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = ThemeManager().getBackgroundColor()
        self.contentView.addSubview(iconImage)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(typeIconImageView)
        self.iconImage.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 50, height: 50))
            make.top.equalToSuperview().offset(10)
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.iconImage.snp.bottom).offset(10)
        }
        
        self.typeIconImageView.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.iconImage.snp.trailing).offset(3)
            make.bottom.equalTo(self.iconImage.snp.bottom).offset(5)
            make.size.equalTo(CGSize(width: 21, height: 21))
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
