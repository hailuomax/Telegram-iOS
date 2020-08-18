//
//  GroupVC.swift
//  TelegramUI
//
//  Created by hailuo on 2019/10/8.
//  Copyright © 2019 Telegram. All rights reserved.
//

import UIKit
import TelegramCore
import Display
import AccountContext
import SyncCore
import Language
import RxSwift
import RxRelay
import Repo
import HL
import Account

class GroupVC: UIViewController {
    
    let context: AccountContext
    
    /// 群的类型
    fileprivate enum SectionType: Int {
        case myCreate, myManager, myJoin, openTrading
        
        func headerTitle() -> String{
            switch self{
            case .myCreate:
                return HLLanguage.GroupsIcreated.localized()
            case .myManager :
                return HLLanguage.GroupsImanage.localized()
            case .myJoin :
                return HLLanguage.GroupsIjoin.localized()
            case .openTrading:
                return HLLanguage.GroupsOpenTrading.localized()
            }
        }
    }
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private let biluRepo: BiLuRepo = BiLuRepo()
    private let disposeBag = DisposeBag()
    ///获取所有群组的序列
    let groupAry: BehaviorRelay<[TelegramGroup]> = BehaviorRelay<[TelegramGroup]>(value: [])
     
    private var myCreateGroups : [TelegramGroup] = []
    ///我管理的群聊数组
    private var myManageGroups : [TelegramGroup] = []
    ///我加入的群聊数组
    private var myJoinedGroups : [TelegramGroup] = []
    ///我開通交易的群聊数组
    private var myTradingGroups : [TelegramGroup] = []
    
    ///展开的标记
    private var openFlag : SectionType? = nil
    ///头部数组
    private let headers : [GroupsHeaderView] = [GroupsHeaderView.create(),GroupsHeaderView.create(),GroupsHeaderView.create(),GroupsHeaderView.create()]

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
        requestTradingGroup()
    }
    
}

extension GroupVC {
    
    private func setBind(){
        
        groupAry.subscribe(onNext: {[weak self] in
            guard let self = self
                , $0.count > 0 else {return}
            self.myCreateGroups.removeAll()
            self.myManageGroups.removeAll()
            self.myJoinedGroups.removeAll()
            $0.forEach{
                switch $0.role{
                case .creator(let rank):
                    self.myCreateGroups.append($0)
                case .admin(_, let rank):
                    self.myManageGroups.append($0)
                case .member:
                    self.myJoinedGroups.append($0)
                }
            }
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
    }
    
    private func setViews() {
        
        tableView.tableFooterView = UIView()
        tableView
            .adhere(toSuperView: view)
            .layout(snapKitMaker: {
                $0.edges.equalToSuperview()
            })
            .config({
                $0.registerCellNib(GroupsChatListCell.self)
                $0.rowHeight = 50
                $0.estimatedRowHeight = 50
                $0.separatorStyle = .none
                $0.showsVerticalScrollIndicator = false
                $0.backgroundColor = UIColor.white
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
        case .openTrading:
            return myTradingGroups.count
        case .none: return 0
        }
    }
    ///section对应的群数组
    private func cellModels(section: Int) -> [TelegramGroup]{
        let sectionType = SectionType(rawValue: section)
        switch sectionType {
        case .myCreate:
            return myCreateGroups
        case .myManager:
            return myManageGroups
        case .myJoin:
            return myJoinedGroups
        case .openTrading:
            return myTradingGroups
        case .none:
            return []
        }
    }
    ///请求自己开通的群
    private func requestTradingGroup(){
        
        guard HLAccountManager.walletIsLogined else {return}
        biluRepo.list()
            .value({[weak self] in
                guard let self = self else {return}
                self.myTradingGroups = $0.compactMap({ one in
                    return self.groupAry.value.filter({"\($0.id.id)" == one.telegramId}).first
                })
                self.tableView.reloadData()
            }).netWorkState({
                switch $0{
                case .success:
                    HUD.hide()
                case .loading:
                    HUD.show(.systemActivity)
                case .error(let er):
                    HUD.flash(.label(er.msg))
                }
            }).load(disposeBag)
    }
}

extension GroupVC : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cellModel = cellModels(section: indexPath.section)[indexPath.row]
        
        let cell = GroupsChatListCell.cellWithTableView(tableView)
        cell.context = context
        cell.loadGroupModel(cellModel)
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
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return myTradingGroups.count == 0 ? 3 : 4
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
