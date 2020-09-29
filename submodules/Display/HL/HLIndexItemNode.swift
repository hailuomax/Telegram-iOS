//
//  HLIndexNode.swift
//  Display#shared
//
//  Created by fan on 2020/9/28.
//

import Foundation
import UIKit
import AsyncDisplayKit
import CoreText

public class HLIndexItemNode : ASDisplayNode {
    
    //添加背景Node
    public var backgroundNode: ImageNode
    public var isHighlight: Bool = false
    public var textNode: ImmediateTextNode
    
    public override init() {
        self.backgroundNode = ImageNode()
        self.textNode = ImmediateTextNode()
        super.init()
        
        self.backgroundNode.backgroundColor = UIColor(hexString: "359AFF")
        self.addSubnode(backgroundNode)
        self.addSubnode(textNode)
    }
    
    public func updateLayout(_ constrainedSize: CGSize) -> CGSize  {
        
        let textNodeSize = textNode.updateLayout(constrainedSize)
        if isHighlight {
            let width = textNodeSize.height 
            let x = ( textNodeSize.width - width) / 2
            self.backgroundNode.frame = CGRect(x: x, y: 0, width: width, height: width)
            self.backgroundNode.cornerRadius = textNodeSize.height / 2
            self.backgroundNode.isHidden = false
        }else {
            backgroundNode.isHidden = true
        }
        textNode.frame = CGRect(x:0, y:0, width:self.frame.width, height: self.frame.height)
        return textNodeSize
    }
}
