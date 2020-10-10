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

let kSectionEdge = UIEdgeInsets(top: 6, left: 15, bottom: 6, right: 15)

let kSectionWidth = kScreenWidth - kSectionEdge.left - kSectionEdge.right

class NewDiscoverVC: HLBaseVC<NewDiscoverView> {
    
    lazy var headerBgView : UIView = UIView()
    
    var gradientLayer = CAGradientLayer()
    
    lazy var viewModel = ViewModel.Discover()
    
    lazy var dataSource: RxCollectionViewSectionedReloadDataSource<Model.Discover.Section> = createDataSources()
    
    override init(context: TGAccountContext?, presentationData: PD? = nil) {
        super.init(context: context, presentationData: presentationData)
        
        let icon = UIImage(bundleImageName: "Chat List/Tabs/IconFound")
        self.tabBarItem.image = icon
        self.tabBarItem.selectedImage = icon
        self.tabBarItem.title = HLLanguage.Tabbar.Discover.str
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        setUI()
        bindUI()
        contentView.collectionView.jy.startRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.updateTheme()
//        if needShowGuide == true {
//            showGuide()
//        }
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
        
        self.contentView.layout(snapKitMaker: {
            $0.top.equalTo(0)
            $0.left.equalToSuperview()
            $0.width.equalTo(kScreenWidth)
            $0.bottom.equalTo(-TabBarHeight)
        })

        self.displayNavigationBar = false
        
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
        let output = viewModel.transform(input: Discover.Input(refresh: contentView.collectionView.rx.onRefresh))
        
        output.isRefreshing.bind(to: contentView.collectionView.rx.isRefreshing).disposed(by: disposeBag)
        
        output.sections.drive( contentView.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    func createDataSources() -> RxCollectionViewSectionedReloadDataSource<Model.Discover.Section> {
        
        return RxCollectionViewSectionedReloadDataSource<Model.Discover.Section>.init(configureCell: { (ds, collectionView, indexPath, section) -> UICollectionViewCell in
            switch section {
            case .banner(let list):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverBannerCell", for: indexPath) as! DiscoverBannerCell
                cell.setModel(list: list)
                return cell
                
            case .sysMessage(let list):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverNoticeCell", for: indexPath)
                return cell
                
            case .hot(let item):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverItemCollectionCell", for: indexPath) as! DiscoverItemCollectionCell
                cell.setItem(item: item)
                return cell
                
            case .recommend(let list):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverRecommendCell", for: indexPath)
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
                default:
                    view.titleLabel.text = ds[indexPath.section].header

                }
                return view
            }else {
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
                return view
            }
        })
            
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
            return CGSize(width: kSectionWidth, height: 107)
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
            return CGSize(width: kSectionWidth, height: 20 + kSectionEdge.bottom)
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
    }
    
}

