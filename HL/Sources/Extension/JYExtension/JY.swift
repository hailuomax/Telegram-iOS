//
//  JY.swift
//  JY
//  自己写的扩展，都带这个前缀
//  Created by 黄国坚 on 2019/5/9.
//  Copyright © 2019 JY. All rights reserved.
//

import Foundation

///以下声明的类型可以调用.jy 命名空间
extension Date: JYNameSpace{}
extension Data: JYNameSpace{}
extension String: JYNameSpace{}
extension NSAttributedString: JYNameSpace{}

public protocol JYNameSpace {
    associatedtype T
    var jy: T { get }
    static var jy: T.Type { get }
}

public extension JYNameSpace {
    var jy: JY<Self> {
        return JY<Self>(base: self)
    }

    static var jy: JY<Self>.Type {
        return JY<Self>.self
    }
}

public struct JY<Base> {
	
	let base: Base
	
	init(base: Base) {
		self.base = base
	}
}



/**只有debug时才会print*/
func JY_DebugPrint(_ msg: Any? = nil, fileName: String = #file, methodName: String = #function, lineNumber: Int = #line){
    
    #if DEBUGSWIFT // 若是Debug模式下，则打印
    let tmp = msg != nil ? """
        打印信息:
        \(String(describing: msg))
        """ : ""
    print("""
        -------------------------------------------
        \((fileName as NSString).lastPathComponent)
        行号:\(lineNumber)
        方法:\(methodName)
        \(tmp)
        -------------------------------------------
        """)
    #endif
}
