//
//  DiscoverItemCell.swift
//  TelegramUI
//
//  Created by fan on 2020/9/30.
//

import UIKit
import Model
import Extension

class DiscoverItemCollectionCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var redDotView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func setItem(item: Model.Discover.Header.Item){
        titleLabel.text = item.linkName
        
        imageView.setImage(urlString: item.linkIcon, placeholder: nil)
    }


}
