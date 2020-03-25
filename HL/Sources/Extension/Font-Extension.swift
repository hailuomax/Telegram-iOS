//
//  Font-Extension.swift
//  TelegramUI
//
//  Created by ERER on 2019/9/27.
//  Copyright © 2019 Telegram. All rights reserved.
//

import UIKit



public enum FontEnum: String {
    
    case k_pingFangSC_Light = "PingFangSC-Light"
    case k_pingFangSC_Bold = "PingFangSC-Semibold"
    case k_pingFangSC_Thin = "PingFangSC-Thin"
    case k_pingFangSC_Regular = "PingFangSC-Regular"
    case k_pingFangSC_Medium = "PingFangSC-Medium"
    case k_helveticaNeue_condensedBlack = "HelveticaNeue-CondensedBlack"
    
    public func toFont(_ size: CGFloat) -> UIFont{
        return UIFont(name: self.rawValue, size: size)!
    }
}
