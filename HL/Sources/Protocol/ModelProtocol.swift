//
//  ModelProtocol.swift 与模型相关的协议都放这里
//  HL
//
//  Created by 黄国坚 on 2020/3/23.
//

import Foundation


//MARK: - 输入输出协议
/// 输入输出协议
protocol InputOutputStype {
    
    ///定义的输入类型
    associatedtype Input
    
    ///定义的输出类型
    associatedtype Output
    
    
    /// 具体转换方法
    func transform(input: Input) -> Output
}
