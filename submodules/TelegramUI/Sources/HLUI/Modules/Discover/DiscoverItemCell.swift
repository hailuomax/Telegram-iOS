//
//  DiscoverItemCell.swift
//  TelegramUI
//
//  Created by tion126 on 2020/1/8.
//  Copyright © 2020 Telegram. All rights reserved.
//

import UIKit

class DiscoverItemCell: UITableViewCell {

    @IBOutlet weak var viewAllLabel: UILabel!
    @IBOutlet weak var redDot: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var needGuide = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }    
}
