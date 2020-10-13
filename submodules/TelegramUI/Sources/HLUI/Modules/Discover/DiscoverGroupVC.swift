//
//  DiscoverGroupVC.swift
//  TelegramUI
//
//  Created by tion126 on 2020/1/16.
//  Copyright © 2020 Telegram. All rights reserved.
//

import UIKit
import AccountContext
import HLBase
import ViewModel
import HL
import Extension
import Model
import Config
import Language

class DiscoverGroupVC: HLBaseVC<DiscoverGroupView> {
    
    var groupVCs   = [DiscoverDetailVC]()
    let viewModel : DiscoverGroupVM
    
    init(context: AccountContext?,viewModel:DiscoverGroupVM) {
        self.viewModel = viewModel
        super.init(context: context)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView(){
        super.loadView()
        self.setUI()
        self.setBind()
        self.getGroupTypes()
    }
    
    func setUI(){
        self.setNavigationBar()
        self.contentView.layout(snapKitMaker: {
            $0.edges.equalToSuperview()
        })
    }
    
    func setupSegmentView(){
        self.contentView.segmentView?.removeFromSuperview()
        var style = SegmentStyle()
        style.selectedTitleColor = ColorEnum.kBlue.toColor()
        style.normalTitleColor = ColorEnum.k999999.toColor()
        style.scrollLineColor = ColorEnum.kBlue.toColor()
        style.showLine = true
        style.scrollLineWidth = 20
        style.scrollLineHeight = 1
        style.equipartition = false
        style.titleFont = FontEnum.k_pingFangSC_Medium.toFont(14)
        self.contentView.segmentView = IMSegmentView(frame: CGRect(x: 0, y: NavBarHeight, width: kScreenWidth, height: kScreenHeight - NavBarHeight - 44), viewControllers: self.groupVCs,segmentStyle: style,segmentViewFrame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 44)).then{
            $0.titleSegmentItemsView.backgroundColor = ColorEnum.kGrayBackground.toColor()
            $0.didSelectedSegmentAtIndexBlock = { _ in}
        }
        self.contentView.segmentView?.didSelectedSegmentAtIndexBlock = { [weak self] in
            self?.view.disablesInteractiveTransitionGestureRecognizer = $0 != 0
        }
        self.contentView.addSubview(self.contentView.segmentView!)
    }

    func setBind(){
        //设置数据
        self.viewModel.dataChange.subscribe (onNext: { [weak self] (alertStr) in
            guard let self = self else {return}
            
            let allModel = DiscoverGroupTypeModel()
            allModel.name = "全部"
            let groupTypeDatas = self.viewModel.groupTypeDatas + [allModel]
            
            let groupVCs = groupTypeDatas.map{(model) -> DiscoverDetailVC in
                let detailVM = DiscoverDetailVM()
                detailVM.groupTypeModel = model
                let detailVC = DiscoverDetailVC(context: self.context, viewModel: detailVM)
                detailVC.title = model.name
                return detailVC
            }
            self.groupVCs = groupVCs
            self.setupSegmentView()
            
        }).disposed(by: self.disposeBag)
    }
    
    func getGroupTypes(){
        
        self.viewModel.getGroupType()
            .netWorkState {[weak self](state) in
                guard let self = self else {return}
                switch state {
                case .loading:
                    HUD.show(.systemActivity,onView: self.view,dismiss:false,marginTop:true)
                case .success:
                    HUD.hide()
                case .error(let error):
                    HUD.show(.systemActivity, onView: self.view,dismiss:false,marginTop:true)
                    HUD.retryShow(animated: true,tips: error.msg, retryBlock: { [weak self] in
                        self?.getGroupTypes()
                    })
                }
        }.load(disposeBag)
    }
}

extension DiscoverGroupVC: NavigationBarType{
     
    var titleView: UIView{
        return createTitleViewWith("热门交流群")
       }
}

class DiscoverGroupView :  BaseContentViewType{
    var segmentView : IMSegmentView?
}
