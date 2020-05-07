//
//  GroupsChatListCell.swift
//  LiaoLiao
//
//  Created by lxtx on 2019/8/12.
//  Copyright © 2019 链行天下. All rights reserved.
//

import UIKit
import TelegramCore
import AccountContext
import Extension
import AvatarNode
import SyncCore
import UI

///群聊列表
class GroupsChatListCell: UITableViewCell {
    
    var context: AccountContext!
    
    ///群名标签
    private let groupNameLabel: UILabel = UILabel().then{
        $0.textColor = UIColor.hex(.k333333)
        $0.font = FontEnum.k_pingFangSC_Medium.toFont(16)
    }
    ///群聊头像
    private let groupImgV: UIImageView = UIImageView()
    private let avatarNode: AvatarNode = AvatarNode(font: FontEnum.k_pingFangSC_Bold.toFont(15.0)).then{
        $0.frame.size = CGSize(width: 40, height: 40)
    }
    
    open class func cellWithTableView(_ tableView: UITableView) -> GroupsChatListCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: GroupsChatListCell.defalutId) as? GroupsChatListCell
        if cell == nil {
            cell = GroupsChatListCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: GroupsChatListCell.defalutId)
        }
        return cell!
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        contentView.addSubview(groupImgV)
        contentView.addSubview(groupNameLabel)
        groupImgV.addSubnode(avatarNode)
        layoutView()
    }
    
    func layoutView() {
        
        groupImgV.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(32)
            make.width.equalTo(groupImgV.snp.height)
            make.top.bottom.equalToSuperview().inset(5)
        }
        
        groupNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(groupImgV.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
    }
}

extension GroupsChatListCell {

    public func loadGroupModel(_ m : TelegramGroup){
        groupNameLabel.text = m.title

        PeerUtil.setAvatar(context: context, peerId: m.id, avatarNode, nil)

        self.contentView.layoutIfNeeded()
    }

    public func loadChanelModel(_ m : TelegramChannel){
        groupNameLabel.text = m.title

        PeerUtil.setAvatar(context: context, peerId: m.id, avatarNode, nil)

        self.contentView.layoutIfNeeded()
    }
}
