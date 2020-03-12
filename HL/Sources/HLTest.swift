import Foundation
import Then
import RxSwift
import Moya
import Kingfisher
import RxRelay
import PromiseKit
import SwiftyJSON

public class HLTest {
    
    
    public init(){
        print("海螺激活")
        
        let t = AAA(a: 0, b: "哈哈").with {
            $0.b = "啊啊啊啊啊啊啊啊a"
        }
        print(t)
    }
}

struct AAA: Then {
    let a: Int
    var b: String
}
