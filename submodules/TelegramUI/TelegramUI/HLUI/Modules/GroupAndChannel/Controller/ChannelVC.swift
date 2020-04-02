//
//  ChannelVC.swift
//  TelegramUI
//
//  Created by apple on 2019/10/8.
//  Copyright © 2019 Telegram. All rights reserved.
//

import Foundation
import UIKit
import TelegramCore
import Display
import AccountContext
import Language
import RxCocoa
import RxSwift
import SyncCore
import Extension

class ChannelVC: UIViewController {
    
    private let context: AccountContext
    
    /// 群的类型
    fileprivate enum SectionType: Int {
        case myCreate, myManager, myJoin
        
        func headerTitle() -> String{
            switch self{
            case .myCreate:
                return Language.ChannelsIcreated.localized()
            case .myManager :
                return Language.ChannelsImanage.localized()
            case .myJoin :
                return Language.ChannelsIjoined.localized()
            }
        }
    }
    
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private let disposeBag = DisposeBag()

    
    ///获取所有群组的序列
    let groupAry: ReplaySubject<[TelegramChannel]> = ReplaySubject<[TelegramChannel]>.create(bufferSize: 1)
    
    private var myCreateGroups : [TelegramChannel] = []
    ///我管理的群聊数组
    private var myManageGroups : [TelegramChannel] = []
    ///我加入的群聊数组
    private var myJoinedGroups : [TelegramChannel] = []
    
    ///展开的标记
    private var openFlag : SectionType? = nil
    ///头部数组
    private let headers : [GroupsHeaderView] = [GroupsHeaderView.create(),GroupsHeaderView.create(),GroupsHeaderView.create()]
    
    init(context: AccountContext){
        self.context = context
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
        setBind()
    }
}

extension ChannelVC {
    
    private func setBind(){
        
        groupAry.subscribe(onNext: {[weak self] in
            guard let self = self
                , $0.count > 0 else {return}
            self.myCreateGroups.removeAll()
            self.myManageGroups.removeAll()
            self.myJoinedGroups.removeAll()
            $0.forEach{
                
                if $0.flags ==  TelegramChannelFlags.isCreator{
                    self.myCreateGroups.append($0)
                }else if $0.adminRights != nil{
                    self.myManageGroups.append($0)
                }else{
                    self.myJoinedGroups.append($0)
                }
            }
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
    }
    
    private func setViews() {
        
        tableView
            .adhere(toSuperView: view)
            .layout(snapKitMaker: {
                
                $0.edges.equalToSuperview()
            })
            .config({
//                $0.registerCellNib(GroupsChatListCell.self)
                $0.rowHeight = 60
                $0.estimatedRowHeight = 60
                $0.separatorStyle = .none
                $0.showsVerticalScrollIndicator = false
                $0.delegate = self
                $0.dataSource = self
            })
        
        
        headers
            .enumerated()
            .forEach({
                let (section, header) = $0
                header.btn.rx
                    .tap
                    .subscribe(onNext: {[weak self] _ in
                        guard let self = self else {return}
                       if self.openFlag != SectionType(rawValue: section){
                            self.openFlag = SectionType(rawValue: section)
                        }else {
                            self.openFlag = nil
                        }
                        self.tableView.reloadData()
                    })
                    .disposed(by: disposeBag)
            })
    }
    
    ///section对应的群数量
    private func sectionCount(_ type: SectionType?) -> Int {
        switch type{
        case .myCreate:
            return myCreateGroups.count
        case .myManager:
            return myManageGroups.count
        case .myJoin:
            return myJoinedGroups.count
        case .none:
            return 0
        }
    }
    ///section对应的群数组
    private func cellModels(section: Int) -> [TelegramChannel]{
        let sectionType = SectionType(rawValue: section)
        switch sectionType {
        case .myCreate:
            return myCreateGroups
        case .myManager:
            return myManageGroups
        case .myJoin:
            return myJoinedGroups
        case .none:
            return []
        }
    }
}

extension ChannelVC : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellModel = cellModels(section: indexPath.section)[indexPath.row]
        
        let cell = GroupsChatListCell.cellWithTableView(tableView)
        cell.context = context
//        cell.loadChanelModel(cellModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cellModel = cellModels(section: indexPath.section)[indexPath.row]
        guard let nv = self.view.superview?.asdk_associatedViewController?.navigationController as? NavigationController else {
            print("没有找到导航栏")
            return
        }
    context.sharedContext.navigateToChatController(NavigateToChatControllerParams(navigationController: nv, context: context, chatLocation: .peer(cellModel.id)))
//        navigateToChatController(navigationController: nv, context: context, chatLocation: .peer(cellModel.id))
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = SectionType(rawValue: section)
        
        return sectionType == openFlag ? sectionCount(sectionType) : 0
    }
    
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = headers[section]
        
        let currentSection = SectionType(rawValue: section)
        let count = sectionCount(currentSection)
        
        let isOpen = openFlag == currentSection
        
        header.model = GroupsHeaderView.Model(title: currentSection?.headerTitle() ?? "", count: count, isOpen: isOpen)

        return header
    }
}
