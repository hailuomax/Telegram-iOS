//
//  DiscoverBannerCell.swift
//  TelegramUI
//
//  Created by fan on 2020/9/30.
//

import UIKit
import Model
import HL
import RxSwift
import RxCocoa

class DiscoverBannerCell: UICollectionViewCell {

    @IBOutlet var bannerView: ZCycleView!
    
    private var list : [Model.Discover.Banner.Item] = []
    
    var disposeBag = DisposeBag()
    
    var gradientLayerDidChange = PublishSubject<[CGColor]>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bannerView.delegate = self
        bannerView.timeInterval = 3
        backgroundColor = .clear
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func setModel(list:[Model.Discover.Banner.Item]) {
        self.list = list
        bannerView.setUrlsGroup(list.map{$0.linkIcon})
    }
    
}

extension DiscoverBannerCell : ZCycleViewProtocol {
    
    func cycleViewConfigureDefaultCellImageUrl(_ cycleView: ZCycleView, imageView: UIImageView, imageUrl: String?, index: Int) {
        imageView.contentMode     = .scaleToFill
        imageView.backgroundColor = .clear
        imageView.setImage(urlString: imageUrl, placeholder: "bg-banner-placeholder")
    }

    func cycleViewDidSelectedIndex(_ cycleView: ZCycleView, index: Int) {
        let model = self.list[index]
//        if model.linkType == 6,let link = model.link ,link == "http://\(Scheme.i7_app)/jumpExchange" {
//            self.validate {[weak self] in
//                guard let self = self else {return}
//                let squareVC = ExchangeSquareVC(context: self.context)
//                self.navigationController?.pushViewController(squareVC, animated: true)
//            }
//            return
//        }
//        resolveURL(self.viewModel.bannerDatas[index])
    }
    
    func cycleViewDidScroll(_ cycleView: ZCycleView, contentOffset: CGPoint) {
        let x = contentOffset.x
        let width = self.contentView.frame.size.width
        let current = Int(floor(x / width).truncatingRemainder(dividingBy: CGFloat(self.list.count)))
        let next = current > self.list.count - 2 ? 0 : current + 1
        let currentColor = self.list[current].color.components(separatedBy: "-")
        let nextColor = self.list[next].color.components(separatedBy: "-")
        
        let startColor1 = UIColor.hexString(currentColor.first)
        let endColor1 = UIColor.hexString(nextColor.first)
        let startColor2 = UIColor.hexString(currentColor.last)
        let endColor2 = UIColor.hexString(nextColor.last)
        let coe = x.truncatingRemainder(dividingBy: width) / width

        let mixColor1 = UIColor.mixColor(startColor: startColor1, endColor: endColor1, coe: coe)
        let mixColor2 = UIColor.mixColor(startColor: startColor2, endColor: endColor2, coe: coe)
        gradientLayerDidChange.onNext([mixColor1.cgColor,mixColor2.cgColor])
    }
    
}
 
