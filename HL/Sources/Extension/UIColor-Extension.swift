//
//  UIColor-Extension.swift
//  TelegramUI
//
//  Created by 黄国坚 on 2019/9/25.
//  Copyright © 2019 Telegram. All rights reserved.
//

import UIKit

extension UIColor {
	
	/// 颜色扩展
	static func hex(_ hex : ColorEnum, alpha:CGFloat = 1) -> UIColor{
		
		return hexInt32(hex.rawValue, alpha: alpha)
	}
	
	
	/// 不常用的颜色可以直接用hexInt32
	static func hexInt32(_ hex : Int32, alpha : CGFloat = 1.0) -> UIColor{
		
		let r = CGFloat((hex & 0xff0000) >> 16) / 255
		let g = CGFloat((hex & 0xff00) >> 8) / 255
		let b = CGFloat(hex & 0xff) / 255
		return UIColor(red: r, green: g, blue: b, alpha: alpha)
	}
    
    static func hexString(_ hexString : String?, alpha : CGFloat = 1.0) -> UIColor{
        
        guard var hexString = hexString else {
            return .white
        }
        
        hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let scanner = Scanner(string: hexString)
        
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    static func mixColor(startColor : UIColor,endColor : UIColor,coe : CGFloat = 1) -> UIColor{
        
        var startR : CGFloat = 0,startG : CGFloat = 0,startB : CGFloat = 0,startA : CGFloat = 0
        
        startColor.getRed(&startR, green: &startG, blue: &startB, alpha: &startA)
        
        var endR : CGFloat = 0,endG : CGFloat = 0,endB : CGFloat = 0,endA : CGFloat = 0
        
        endColor.getRed(&endR, green: &endG, blue: &endB, alpha: &endA)
        
        let differR : CGFloat = endR - startR,differG : CGFloat = endG - startG,differB : CGFloat = endB - startB,differA : CGFloat = endA - startA
        
        let mixR : CGFloat = startR + differR * coe,mixG : CGFloat = startG + differG * coe,mixB : CGFloat = startB + differB * coe,mixA : CGFloat = startA + differA * coe
        
        return UIColor(red: mixR, green: mixG, blue: mixB, alpha: mixA)
    }
}

/// 项目内颜色枚举
enum ColorEnum: Int32 {
	typealias RawValue = Int32
	
    case ka1a1a1 = 0xa1a1a1
    case k878B9F = 0x878B9F
    case k666666 = 0x666666
	case k999999 = 0x999999
    
    //红包系列
    case kFF9A4E = 0xFF9A4E
    case kFF4545 = 0xFF4545
    case kF7C8AB = 0xF7C8AB
    case kF7A4A5 = 0xF7A4A5
    case kFFEBDB = 0xFFEBDB
    case kFF9A58 = 0xFF9A58
    case kF7F7F7 = 0xF7F7F7
    case kFFB292 = 0xFFB292
    
    //转账系列
    case k88DBE9 = 0x88DBE9
    case kFFB400 = 0xFFB400
    case kFF933E = 0xFF933E
    case kFFE2C2 = 0xFFE2C2
    
    // 灰色系
    case kGrayBackground = 0xF6F6F6
    case kGrayLight = 0xE4E4E4
    case kGray = 0xDDDDDD
    case kGrayBorder = 0xCCCCCC
    case kAAAAAA = 0xAAAAAA
    
    //蓝色系
    case kBlue = 0x0079E2
    case kE1EFFB = 0xE1EFFB
    case k477ECD = 0x477ECD
    case k5AACFF = 0x5AACFF
    case k3599FC = 0x3599FC
    case k68B4FF = 0x68B4FF
    case k429BFF = 0x429BFF
    case k4FB8FF = 0x4FB8FF
    case k3493FF = 0x3493FF
    case kA1D3FB = 0xA1D3FB
    case k91BFFA = 0x91BFFA
    case kF2F7FF = 0xF2F7FF
    case k42A5FF = 0x42A5FF
    case k0091FF = 0x0091FF
    case k2AA3FF = 0x2AA3FF
    case kDBECFF = 0xDBECFF
    
    //闪兑
    case k3FC33B = 0x3FC33B
    case k6FB26A = 0x6FB26A
    
    case kEFF0F1 = 0xEFF0F1
    case k19D5AE = 0x19D5AE
    case k0A0B13 = 0x0A0B13

    case k44C06E = 0x44C06E
    case kFF4949 = 0xFF4949
    
    case k54A627 = 0x54A627
    case kF7B500 = 0xF7B500
    case kFF3636 = 0xFF3636
    
    case k333333 = 0x333333
    
    func toColor(_ alpha: CGFloat = 1) -> UIColor {
        return UIColor.hexInt32(self.rawValue, alpha: alpha)
    }

}
