//
//  DiscoverItemCell.swift
//  TelegramUI
//
//  Created by fan on 2020/9/30.
//

import UIKit
import Model
import Extension
import HL

class DiscoverItemCollectionCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var redDotView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        redDotView.isHidden = true
    }
    
    func setItem(item: Model.Discover.Item){
        titleLabel.text = item.linkName
        redDotView.isHidden = true
        imageView.setImage(urlString: item.linkIcon, placeholder: "ic-discover-default")
        
        if item.refCode == Model.Discover.RefCode.notice.rawValue { //系统通知
            redDotView.isHidden = !(Defaults[HLDefaultsKey.HasNewSystemMessage].bool ?? true)
        }else if item.refCode == Model.Discover.RefCode.welfareBot.rawValue {// 福利
            redDotView.isHidden = !(Defaults[HLDefaultsKey.HasNewWelfareMessage].bool ?? true)
        }
        
    }


}
