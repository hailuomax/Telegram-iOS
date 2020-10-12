//
//  DiscoverNoticeCell.swift
//  TelegramUI#shared
//
//  Created by fan on 2020/10/9.
//

import UIKit
import Model
import Extension
import UI

class DiscoverNoticeCell: UICollectionViewCell {
    
    @IBOutlet var bgView: VerticalBannerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setUI()
    }
    
    func setUI(){
        self.cornerRadius = 7.5
    }

    func setList(list: [Model.Discover.SysMessage.Item]) {
        bgView.repeatShow(dataSources: list, repetitionInterval: 3, withDuration: 0.3) { (item) -> (UIView) in
            let button = UIButton()
            button.titleLabel?.textAlignment = .left
            button.titleLabel?.lineBreakMode = .byTruncatingTail
            button.titleLabel?.font = FontEnum.k_pingFangSC_Medium.toFont(12)
            button.setTitleColor(UIColor(hexString: "#9AA3AC"), for: .normal)
            button.setTitle(item.content, for: .normal)
            return button
        }
    }
}
