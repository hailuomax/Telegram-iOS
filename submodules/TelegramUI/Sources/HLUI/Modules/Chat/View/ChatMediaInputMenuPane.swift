//
//  ChatMediaInputMenuPane.swift
//  TelegramUI
//
//  Created by 黄国坚 on 2019/12/5.
//  Copyright © 2019 Telegram. All rights reserved.
//

import UIKit
import TelegramPresentationData
import LegacyComponents
import Postbox
import TelegramCore
import TelegramPresentationData
import DeviceAccess
import Display
import Extension
import RxSwift
import AccountContext
import SyncCore
import Config
import Extension
import LegacyUI
import Language
import LegacyMediaPickerUI

enum ChatMediaInputMenu: String, Equatable{
    
    case shooting,photo,location,contact,file,redPacket,superRedPacket,transfer,exchange,poll
    
    func index() -> Int{
        switch self {
            case .shooting:return 0
            case .photo:return 1
            case .location:return 2
            case .contact:return 3
            case .file:return 4
            case .redPacket:return 5
            case .superRedPacket:return 6
            case .transfer:return 7
            case .exchange:return 8
            case .poll:return 9
        }
    }
}

/// 聊天页面菜单弹窗（包括发送图片视频，炒鸡红包，普通红包，群红包，闪兑，转账等。。。。）
final class ChatMediaInputMenuPane: ChatMediaInputPane {
    
    ///选项
    private var menus: [ChatMediaInputMenu] = []
    let contentView: ChatMediaInputMenuView
    
    init(menus: [ChatMediaInputMenu], onSelect: @escaping (ChatMediaInputMenu)->()){
        
        let view = Bundle.getAppBundle().loadNibNamed("ChatMediaInputMenu", owner: nil, options: nil)![0] as! ChatMediaInputMenuView
        self.contentView = view
        super.init()
        self.setViewBlock { return self.contentView }
    }
    
    func sendImgs() {
        if let carouselItem = self.contentView.carouselItem {
            let intent: TGMediaAssetsControllerIntent = TGMediaAssetsControllerSendMediaIntent
            let signals = TGMediaAssetsController.resultSignals(for: carouselItem.selectionContext, editingContext: carouselItem.editingContext, intent: intent, currentItem: nil, storeAssets: true, useMediaCache: false, descriptionGenerator: legacyAssetPickerItemGenerator(), saveEditedPhotos: false)
            if let sendMessagesWithSignals = self.contentView.sendMessagesWithSignals {
                sendMessagesWithSignals(signals, false)
            }
        }
        self.contentView.carouselItem?.clearImgs()
    }
}

final class ChatMediaInputMenuView: UIView{
    
    private let disposeBag = DisposeBag()
    
    /// 规定每页两行
    static let lineCount: Int = 2
    
    @IBOutlet weak var CarouseItemView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var superStackView: UIStackView!
    @IBOutlet weak var pageControl: UIPageControl!
    var carouselItem: TGAttachmentCarouselItemView?
    var selectImgs: ((Int) -> ())? = nil
    var sendMessagesWithSignals: (([Any]?, Bool) -> ())? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollView.rx.contentOffset.subscribe(onNext: {[weak self] in
            guard let self = self else { return }
            self.pageControl.currentPage = Int($0.x / self.scrollView.bounds.size.width)
        }).disposed(by: disposeBag)
    }
    
    private func addCarouseView(context: AccountContext,presentationData: PresentationData , peer: Peer, editMediaOptions: MessageMediaEditingOptions?, saveEditedPhotos: Bool, allowGrouping: Bool, theme: PresentationTheme, strings: PresentationStrings, parentController: LegacyController, initialCaption: String, sendMessagesWithSignals: @escaping ([Any]?, Bool) -> (), openGallery: @escaping () -> () , openMediaPicker: @escaping () -> () , closeMediaPicker: @escaping () -> () )  {
        self.sendMessagesWithSignals = sendMessagesWithSignals
//        let controller = TGMenuSheetController(context: parentController.context, dark: false)!
//        controller.dismissesByOutsideTap = true
//        controller.hasSwipeGesture = true
//        controller.maxHeight = 445.0
//        controller.forceFullScreen = true
        let isSecretChat = peer.id.namespace == Namespaces.Peer.SecretChat
        var selectionLimit: Int32 = 30
        var slowModeEnabled = false
        if let channel = peer as? TelegramChannel, channel.isRestrictedBySlowmode {
            slowModeEnabled = true
            selectionLimit = 10
        }
        carouselItem = TGAttachmentCarouselItemView(context: parentController.context, camera: false, selfPortrait: false, forProfilePhoto: false, assetType: TGMediaAssetAnyType, saveEditedPhotos: !isSecretChat && saveEditedPhotos, allowGrouping: editMediaOptions == nil && allowGrouping, allowSelection: editMediaOptions == nil, allowEditing: true, document: false, selectionLimit: selectionLimit)!
        carouselItem?.suggestionContext = legacySuggestionContext(context: context, peerId: peer.id)
        carouselItem?.recipientName = peer.displayTitle(strings: presentationData.strings, displayOrder: presentationData.nameDisplayOrder)
        carouselItem?.openEditor = false
        carouselItem?.allowCaptions = false
        carouselItem?.allowCaptionEntities = false
        carouselItem?.screenHeight = 96;
        carouselItem?.frame = CGRect(x:0, y:0, width:kScreenWidth, height:96);
        carouselItem?.pickerDidDissmis = closeMediaPicker
        carouselItem?.didSelectRow = openMediaPicker
        carouselItem?.selectImgBlock = { [weak self] selectCount in
            if let selectImgBlock = self?.selectImgs {
                selectImgBlock(selectCount)
            }
        }

        
        if peer.id != context.account.peerId {
            if peer is TelegramUser {
                carouselItem?.hasTimer = true
            }
            carouselItem?.hasSilentPosting = !isSecretChat
        }

        if let carouselItem = carouselItem {
            self.CarouseItemView.addSubview(carouselItem)
        }
    }
    
    public func updateWith(presentationData: PresentationData,context: AccountContext, peer: Peer, editMediaOptions: MessageMediaEditingOptions?, saveEditedPhotos: Bool, allowGrouping: Bool, theme: PresentationTheme, strings: PresentationStrings, parentController: LegacyController, initialCaption: String, menus: [ChatMediaInputMenu], onSelect: @escaping (ChatMediaInputMenu)->(),sendMessagesWithSignals: @escaping ([Any]?, Bool) -> (), openGallery: @escaping ()->() , openMediaPicker: @escaping () -> Void , closeMediaPicker: @escaping () -> Void ) {
        DeviceAccess.authorizeAccess(to: .mediaLibrary(.send), presentationData: presentationData, present: context.sharedContext.presentGlobalController, openSettings: context.sharedContext.applicationBindings.openSettings, { (value) in
            if !value {
                self.CarouseItemView.snp.updateConstraints { (make) in
                    make.height.equalTo(0)
                }
            }
        })
        
        ///先清空superStackView的子view
        for child in superStackView.arrangedSubviews {
            child.removeFromSuperview()
        }
        for child in self.CarouseItemView.subviews {
            child.removeFromSuperview()
        }
        self.addCarouseView(context: context, presentationData: presentationData , peer: peer, editMediaOptions: editMediaOptions, saveEditedPhotos: saveEditedPhotos, allowGrouping: allowGrouping, theme: theme, strings: strings, parentController: parentController, initialCaption: initialCaption,sendMessagesWithSignals:sendMessagesWithSignals, openGallery: openGallery ,openMediaPicker : openMediaPicker ,closeMediaPicker : closeMediaPicker)
        
        var menus = menus
        
        ///每一页的行数
        let lineCount = ChatMediaInputMenuView.lineCount
        ///每一页的列数
        let columnCount = ChatMediaInputMenuLine.columnCount
        let countPerPage = lineCount * columnCount
        //计算需要多少页
        let subPageCount: Int = Int(ceil(CGFloat(menus.count) / CGFloat(countPerPage)))
        pageControl.numberOfPages = subPageCount
        pageControl.isHidden = subPageCount <= 1
        ///一共有多少行
        let subLineCount: Int = Int(ceil(CGFloat(menus.count) / CGFloat(columnCount)))
        
        ///menus三维数组
        var menusAry: [[ChatMediaInputMenu]] = []
        for line in 0..<subLineCount {
            var lineMenus: [ChatMediaInputMenu] = []
            var repeatCount = 0
            repeat{
                lineMenus.append(menus.removeFirst())
                repeatCount += 1
            }while repeatCount < columnCount && menus.count > 0
            menusAry.append(lineMenus)
        }
        
        
        //生成子竖向布局StackView （翻页用的）
        func initChildVerticalStackView(for page: Int, onSelect: @escaping (ChatMediaInputMenu)->()) -> UIView {
            let stackView = UIStackView().then{
                $0.axis = .vertical
                $0.distribution = .fillEqually
                var tmpLineCount = lineCount
                if subLineCount <= lineCount{
                    tmpLineCount = subLineCount
                }else if subPageCount - 1 == page {
                    tmpLineCount = subLineCount / lineCount
                }
                //添加行
                for line in 0..<tmpLineCount{
                    
                    let index = page * lineCount + line
                    let lineMenus: [ChatMediaInputMenu] = menusAry[index]
                    $0.addArrangedSubview(ChatMediaInputMenuLine.create(menus: lineMenus, onSelect: onSelect))
                    
                }
            }
            
            let v = UIView().then{
                $0.addSubview(stackView)
            }
            stackView.snp.makeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.left.right.equalToSuperview().inset(20)
            }
            return v
        }
        
        //生成子横向布局StackView
        /// - Parameters:
        ///   - line: 对应的行下标
        ///   - page: 对应的页下标
        func initChildHorizontalStackView(for line: Int, page: Int, onSelect: @escaping (ChatMediaInputMenu)->()) -> UIStackView{
            return UIStackView().then{
                $0.axis = .horizontal
                $0.spacing = 25
                $0.distribution = .fillEqually
                
                let index = page * lineCount + line
                let lineMenus: [ChatMediaInputMenu] = menusAry[index]
                $0.addArrangedSubview(ChatMediaInputMenuLine.create(menus: lineMenus, onSelect: onSelect))
            }
        }
        
        //添加竖列的StackView
        for page in 0..<subPageCount{
            let childView = initChildVerticalStackView(for: page, onSelect: onSelect)
            
            superStackView.addArrangedSubview(childView)
            
            childView.snp.makeConstraints({
                $0.width.equalTo(self.scrollView)
            })
        }
    }
}


/// 每一行的菜单
final class  ChatMediaInputMenuLine: UIView{
    
    ///暂时写死每页4列
    static let columnCount = 4
    
    @IBOutlet var items: [ChatMediaInputMenuItem]!
    
    // 创建方法
    static func create(menus: [ChatMediaInputMenu], onSelect: @escaping (ChatMediaInputMenu)->()) -> ChatMediaInputMenuLine {
        
        let line = Bundle.getAppBundle().loadNibNamed("ChatMediaInputMenu", owner: nil, options: nil)![1] as! ChatMediaInputMenuLine
        line.setUp(menus: menus, onSelect: onSelect)
        
        return line
    }
    
    private func setUp(menus: [ChatMediaInputMenu], onSelect: @escaping (ChatMediaInputMenu)->()){
        
        for (i, item) in items.enumerated(){
            
            item.updateViews(with: (i < menus.count) ? menus[i] : nil, onSelect: onSelect)
        }
    }
}

final class ChatMediaInputMenuItem: UIControl{
    @IBOutlet weak var logoImgV: UIImageView!{
        didSet{
            logoImgV.contentMode = .center
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    
    private let disposeBag = DisposeBag()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        logoImgV.layer.do{
            $0.cornerRadius = $0.bounds.size.height / 2
            $0.masksToBounds = true
        }
    }
    
    ///更新UI
    func updateViews(with menuType: ChatMediaInputMenu?, onSelect: @escaping (ChatMediaInputMenu)->()){
        
        var title: String
        
        switch menuType {
            
        case .shooting:
            title = HLLanguage.Chat.Menu.shooting.localized()
        case .photo:
            title = HLLanguage.Chat.Menu.photo.localized()
        case .location:
            title = HLLanguage.Chat.Menu.location.localized()
        case .contact:
            title = HLLanguage.Chat.Menu.contact.localized()
        case .file:
            title = HLLanguage.Chat.Menu.file.localized()
        case .redPacket:
            title = HLLanguage.SendRedPacket.localized()
        case .superRedPacket:
            title = HLLanguage.SendSuperPacketMenu.localized()
        case .transfer:
            title = HLLanguage.Transfer.localized()
        case .exchange:
            title = HLLanguage.FastExchange.localized()
        case .poll:
            title = HLLanguage.Chat.Menu.poll.localized()
        case .none:
            title = ""
        default:
            title = ""
        }
        
        var imgVConfig: (UIImage?, UIColor) = (nil, .clear)
        if let menuType = menuType{
            imgVConfig.0 = UIImage(bundleImageName: ("Chat/Menu/" + menuType.rawValue))
            imgVConfig.1 = .white
        }
        logoImgV.do{
            ($0.image,$0.backgroundColor) = imgVConfig
        }
        
        
        titleLabel.text = title
        
        //点击事件
        self.rx.controlEvent(.touchUpInside)
            .subscribe ({[weak self] _ in
                guard let self = self,
                    let menuType = menuType else {return}
                onSelect(menuType)
            })
            .disposed(by: disposeBag)
    }
}
