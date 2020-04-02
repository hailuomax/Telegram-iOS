//
//  GroupsHeaderView.swift
//  LiaoLiao
//
//  Created by lxtx on 2019/8/12.
//  Copyright © 2019 链行天下. All rights reserved.
//

import UIKit
import Extension
import SnapKit


class GroupsHeaderView: UIView {
    
    struct Model {
        var title : String
        var count : Int
        var isOpen : Bool
    }
    
    var model : Model!{
        didSet{
            groupTypeLabel.text = model.title
            countLabel.text = "\(model.count)"
            upLogoImgV.isHighlighted = model.isOpen
        }
    }
    
    
    //群管理类型标签
    private let groupTypeLabel: UILabel = UILabel().then{
        $0.textColor = UIColor.hex(.kBlue)
        $0.font = FontEnum.k_pingFangSC_Regular.toFont(16)
    }

    //群数量标签
    private let countLabel: UILabel = UILabel().then{
        $0.textColor = UIColor.hex(.k999999)
        $0.font = FontEnum.k_pingFangSC_Regular.toFont(14)
    }
    
    //上箭头
    private let upLogoImgV: UIImageView = UIImageView().then{
        $0.image = UIImage(bundleImageName: "contactCloseLogo")
        $0.highlightedImage = UIImage(bundleImageName: "contactOpenLogo")
    }

    let btn: UIButton = UIButton()
    
    ///创建GroupsHeaderView
    static func create() -> GroupsHeaderView {
        let view = GroupsHeaderView()
        view.backgroundColor = .white
        view.addSubview(view.groupTypeLabel)
        view.addSubview(view.countLabel)
        view.addSubview(view.upLogoImgV)
        view.addSubview(view.btn)
        view.upLogoImgV.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
        }
        view.groupTypeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(view.upLogoImgV.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        view.countLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
        }
        view.btn.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        return view
    }
}
