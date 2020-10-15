//
//  RecommendItemCell.swift
//  TelegramUI
//
//  Created by fan on 2020/9/30.
//

import UIKit
import Model
import Extension

class RecommendItemCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var addButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageView.cornerRadius = 25.5
        imageView.layer.masksToBounds = true
        addButton.isUserInteractionEnabled = false
    }

}
