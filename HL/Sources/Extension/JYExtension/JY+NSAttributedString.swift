//
//  JY+NSAttributedString.swift
//  TelegramUI
//
//  Created by 黄国坚 on 2020/2/26.
//  Copyright © 2020 Telegram. All rights reserved.
//

import UIKit

extension JY where Base == NSAttributedString{
    
    ///NSAttributedString 暂时没有通用化
    static func text(_ text: String, lineSpace: CGFloat, fontSize: CGFloat, fontColor: UIColor) -> NSAttributedString{
        let style = NSMutableParagraphStyle().then{$0.lineSpacing = lineSpace}
        
        return NSAttributedString(string: text, attributes:
            [.paragraphStyle : style,
             .font :FontEnum.k_pingFangSC_Regular.toFont(fontSize),
             .foregroundColor : fontColor])
    }
}
