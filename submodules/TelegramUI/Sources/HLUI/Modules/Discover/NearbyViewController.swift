//
//  NearbyViewController.swift
//  TelegramUI
//
//  Created by lemon on 2020/3/23.
//  Copyright © 2020 Telegram. All rights reserved.
//

import UIKit
import TelegramCore
import TelegramPresentationData
import AccountContext
import Kingfisher
import Display
import PeersNearbyUI
import ItemListUI
import HL
import HLBase
import Config
import NameSpace
import Extension

private let maxOffset : CGFloat = 175

class NearbyViewController: HLBaseVC<NearbyView>  {
    
    private var itemControllers : [ItemListController] = []
        
    private var contentScrollViewCanScroll  = true
    
    private var currentScrollView : UIScrollView?
    
    deinit {
        print("NearbyViewController deinit!!!")
    }
    
    override func loadView() {
        super.loadView()
        setUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        itemControllers.forEach{$0.viewDidAppear(animated)}
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        itemControllers.forEach{$0.viewWillDisappear(animated)}
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        itemControllers.forEach{$0.viewDidDisappear(animated)}
    }
    
    override func dismiss(completion: (() -> Void)? = nil) {
        super.dismiss(completion: completion)
        itemControllers.forEach{$0.dismiss(completion: completion)}
    }
    
    override func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
        var newlayout = layout
        newlayout.statusBarHeight = 0
        newlayout.size.height = newlayout.size.height - kDefaultNavHeight - 44
        itemControllers.forEach{$0.containerLayoutUpdated(newlayout, transition: transition)}
    }
    
    func setUI() {
        self.title = presentationData.strings.PeopleNearby_Title
        
        var style = SegmentStyle()
        style.selectedTitleColor = presentationData.theme.list.itemPrimaryTextColor //.black
        style.normalTitleColor = ColorEnum.k666666.toColor()
        style.scrollLineColor = presentationData.theme.list.itemPrimaryTextColor
        style.scrollLineWidth = 20
        style.showLine = true
        style.scrollLineHeight = 2
        style.equipartition = false
        style.titleFont = FontEnum.k_pingFangSC_Medium.toFont(14)
        let viewControllers = self.viewControllers(context: context!)
        viewControllers.forEach {[weak self] (vc) in
            self?.addChild(vc)
        }
        self.itemControllers = viewControllers
        
        let headerNodeHeight : CGFloat = maxOffset
        let segmentViewHeight : CGFloat = kScreenHeight - NavBarHeight - iPhoneXSafeAreaBottom
        self.contentView.segmentView = IMSegmentView(frame: CGRect(x: 0, y: headerNodeHeight, width: kScreenWidth, height: segmentViewHeight), viewControllers: viewControllers,segmentStyle: style,segmentViewFrame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 44) ,type: .node)
        self.contentView.segmentView?.disablesInteractiveTransitionGestureRecognizer = true
        self.contentView.segmentView?.collectionView.isScrollEnabled = false
        self.contentView.segmentView?.collectionView.hl.canGestureRecognize = true
        self.contentView.scrollView.addSubview(self.contentView.segmentView!)
//        self.contentView.segmentView?.titleSegmentItemsView.shadowColor = UIColor.groupTableViewBackground
//        self.contentView.segmentView?.titleSegmentItemsView.shadowOffset = CGSize(width: 0, height: 3)
        
        let node = NearbyHeaderNode(theme: presentationData.theme, text: presentationData.strings.PeopleNearby_Description)
        node.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: headerNodeHeight)
        self.contentView.scrollView.addSubnode(node)
    
        self.contentView.scrollView.contentSize = CGSize(width: kScreenWidth, height: headerNodeHeight + segmentViewHeight)
                self.contentView.backgroundColor = presentationData.theme.list.plainBackgroundColor
        self.contentView.segmentView?.titleSegmentItemsView.backgroundColor = presentationData.theme.list.plainBackgroundColor
        
        self.contentView.scrollView.delegate = self
        for list in itemControllers  {
            let listNode = (list.displayNode as! ItemListControllerNode).listNode
            listNode.hlShouldRecognize(true)
            // 判断子scrollView能不能滚动
            listNode.didScroll = {[weak self] scrollView in
                guard let self = self else {return}
                self.currentScrollView = scrollView
                if !scrollView.hl.childCanScroll {
                    scrollView.contentOffset.y = 0
                }else {
                    if scrollView.contentOffset.y <= 0 {
                        scrollView.hl.childCanScroll = false
                        self.contentScrollViewCanScroll = true
                    }
                }
            }
        }
        
    }
    
    private func viewControllers(context: AccountContext) -> [ItemListController] {
        
        return [NearbyType.user, NearbyType.group].map{
            let nearbyVC = peersNearbyController(context: context, nearbyType:$0)
            nearbyVC.displayNavigationBar = false
            nearbyVC.title = $0.vcTitle
            return nearbyVC
        }
    }
}
//MARK: --UIScrollViewDelegate
extension NearbyViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !contentScrollViewCanScroll && (self.currentScrollView?.hl.childCanScroll ?? false)  {
            scrollView.contentOffset.y = maxOffset
        }else {
            if scrollView.contentOffset.y >= maxOffset {
                contentScrollViewCanScroll = false
                currentScrollView?.hl.childCanScroll = true
                scrollView.contentOffset.y = maxOffset
            }
        }
    }
}
//MARK: --UIScrollView扩展属性判断能否滚动
fileprivate var childCanScrollKey: Void?
extension UIScrollView: HaiLuoObjNameSpace{}
extension HL where Base: UIScrollView {
   public var childCanScroll: Bool {
        get {
            let value = objc_getAssociatedObject(base, &childCanScrollKey) as? Bool
            return value ?? false
        }
        set(newValue){
            objc_setAssociatedObject(base, &childCanScrollKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

//MARK: --NearbyView
class NearbyView : BaseContentViewType {
    
    var segmentView : IMSegmentView?
    
    @IBOutlet weak var scrollView : UIScrollView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollView.bounces = false
    }
    
}


