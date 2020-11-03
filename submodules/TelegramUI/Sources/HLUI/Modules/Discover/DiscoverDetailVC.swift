//
//  DiscoverDetailVC.swift
//  TelegramUI
//
//  Created by tion126 on 2020/1/8.
//  Copyright © 2020 Telegram. All rights reserved.
//

import UIKit
import HLBase
import ViewModel
import AccountContext
import Extension
import HL
import Model
import Language
import RxSwift
import Theme

private let kDiscoverDetailCell = "k\(DiscoverDetailCell.self)"

class DiscoverDetailVC: HLBaseVC<DiscoverDetailView> {

    let viewModel : DiscoverDetailVM
    init(context: AccountContext?,viewModel:DiscoverDetailVM) {
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
        self.initUI()
        self.setBind()
    }
    
    func initUI(){
        self.setNavigationBar()
        
        if self.viewModel.type == .group {
            self.contentView.layout(snapKitMaker: {
                $0.edges.equalToSuperview()
            })
            self.contentView.tableView.tableHeaderView = nil
        }
        self.contentView.tableView.dataSource = self
        self.contentView.tableView.delegate = self
        self.contentView.tableView.register(DiscoverDetailCell.self, forCellReuseIdentifier: kDiscoverDetailCell)
    }
    
    func setBind(){
        
        if self.viewModel.type == .channel {
            self.viewModel.listDatas = self.viewModel.discoverData.list ?? []
            self.contentView.tableView.reloadData()
            return
        }
        
        self.contentView.tableView.jy.onRefresh {[weak self] in
            guard let self = self else { return }
            self.viewModel.getGroupList(1).errorIntercept {[weak self] in
                guard let self = self else {return $0}
                HUD.flash(.label($0.msg), delay: 1, completion: nil)
                self.viewModel.refreshEnd.value(false)
                return $0
            }.load(self.disposeBag)
        }
        
        self.contentView.tableView.jy.onLoadMore{[weak self] in
            guard let self = self else { return }
            self.viewModel.getGroupList(self.viewModel.current + 1).errorIntercept {[weak self] in
                guard let self = self else {return $0}
                HUD.flash(.label($0.msg), delay: 1, completion: nil)
                self.viewModel.refreshEnd.value(false)
                return $0
            }.load(self.disposeBag)
        }
        
        self.contentView.tableView.jy.startRefresh()
                
        self.viewModel.refresh.subscribe(onNext: {[weak self] _ in
            guard let self = self else {return}
            self.contentView.tableView.jy.startRefresh()
        }).disposed(by: disposeBag)
        
        self.viewModel.refreshEnd.subscribe(onNext: {[weak self] in
            guard let self = self else {return}
            self.contentView.tableView.jy.stopRefresh()
            self.contentView.tableView.jy.stopLoadMore($0)
            self.contentView.tableView.reloadData()
        }).disposed(by: disposeBag)
    }
}

extension DiscoverDetailVC : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.listDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kDiscoverDetailCell) as! DiscoverDetailCell
        let model = self.viewModel.listDatas[indexPath.row]
        cell.iconImageView.setImage(urlString: model.linkIcon ?? model.titleIcon, placeholder:"ic-discover-default")
        cell.titleLabel.text = model.name ?? model.linkName
        cell.titleLabel.textColor = .black
        cell.checkButton.rx.tap.asObservable()
            .subscribe(onNext: {[weak self] _ in
                self?.resolveURL(model)
        }).disposed(by: cell.disposeBag)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           tableView.deselectRow(at: indexPath, animated: true)
           let model = self.viewModel.listDatas[indexPath.row]
           self.resolveURL(model)
    }
    
    func resolveURL(_ model : DiscoverListItemModel?){
        guard let link = model?.link , model?.linkType != 4 ,let url = URL(string: link) else {return}
        app.openUrl(url: url)
    }
}

extension DiscoverDetailVC: NavigationBarType{
     
    var titleView: UIView{
        return createTitleViewWith(self.viewModel.discoverData.name ?? HLLanguage.TabBar.Discover.localized())
       }
}

class DiscoverDetailView: BaseContentViewType{
    @IBOutlet weak var tableView: UITableView!
}


class DiscoverDetailCell: UITableViewCell {
    
    let iconImageView : UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.backgroundColor = ColorEnum.kF7F7F7.toColor()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.font = FontEnum.k_pingFangSC_Regular.toFont(16)
        label.textColor = ThemeManager().getTextColor()
        label.textAlignment = .left
        return label
    }()
    
    let line : UIView = {
        let view = UIView()
        view.backgroundColor = ColorEnum.kGray.toColor()
        return view
    }()
    
    let checkButton : UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(HLLanguage.GetInto.localized(), for: .normal)
        button.layer.borderColor = ColorEnum.k007DFF.toColor().cgColor
        button.layer.borderWidth = 0.5
        button.clipsToBounds = true
        button.layer.cornerRadius = 3
        button.setTitleColor(ColorEnum.k007DFF.toColor(), for: .normal)
        button.titleLabel?.font = FontEnum.k_pingFangSC_Regular.toFont(13)
        return button
    }()
    
    var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.addSubview(iconImageView)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(line)
        self.contentView.addSubview(checkButton)
        self.iconImageView.snp.makeConstraints { (make) in
            
            make.leading.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 32, height: 32))
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalTo(self.iconImageView.snp.trailing).offset(15)
            make.trailing.equalTo(self.checkButton.snp.leading).offset(-10)
        }
        
        self.line.snp.makeConstraints { (make) in
            make.bottom.trailing.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
            make.height.equalTo(0.5)
        }
        
        self.checkButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-15)
            make.size.equalTo(CGSize(width: 55, height: 22))
        }


    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.disposeBag = DisposeBag()
    }
       
}
