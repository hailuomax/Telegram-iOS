//
//  UIImage+Color.swift
//  CGWangXueBa
//
//  Created by Engine on 2018/6/15.
//  Copyright © 2018年 CGWang. All rights reserved.
//

import UIKit

extension UIImage{
    
    //MARK: - 重设图片大小
    ///重设图片大小
    func reSizeImage(reSize:CGSize)-> UIImage? {
        UIGraphicsBeginImageContext(reSize)
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    //MARK: - 生成纯颜色图片
    /// 生成纯颜色图片
    class func colorImg(_ color : UIColor) -> UIImage{
        
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    //MARK: - 根据颜色组生成渐变Image
    /// 根据颜色组生成渐变Image
    ///
    /// - Parameters:
    ///   - rect: 大小
    ///   - colors: 颜色
    ///   - type: 方向 0：从上到下 1：从左到右
    /// - Returns: image
    class func setGradientImageWithBounds(rect: CGRect, colors: Array<UIColor>, type: Int) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        let context = UIGraphicsGetCurrentContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = colors.map {(color: UIColor) -> AnyObject? in return color.cgColor as AnyObject? } as NSArray
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: nil)
        // 第二个参数是起始位置，第三个参数是终止位置
        if type == 0 {
            //从上到下
            context!.drawLinearGradient(gradient!, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: rect.size.height), options: CGGradientDrawingOptions(rawValue: 0))
        } else {
            //从左到右
            context!.drawLinearGradient(gradient!, start: CGPoint(x: 0, y: 0), end: CGPoint(x: rect.size.width, y: 0), options: CGGradientDrawingOptions(rawValue: 0))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return (image ?? UIImage())!
    
    }
}

extension UIColor {
    
    /// 生成纯颜色图片
    func image() -> UIImage{
        
        UIImage.colorImg(self)
    }
}
