//
//  DiscoverRecommendCell.swift
//  TelegramUI
//
//  Created by fan on 2020/9/30.
//

import UIKit
import Model
import RxSwift
import RxCocoa
import RxDataSources
import Extension

class DiscoverRecommendCell: UICollectionViewCell {

    @IBOutlet var collectionView: UICollectionView!
    
    var listData = PublishSubject<[Model.Discover.Item]>()
    
    var disposeBag = DisposeBag()
    
    private let bag = DisposeBag()
    
    let didSelectedItem = PublishSubject<Model.Discover.Item>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUI()
        bindUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func setUI(){
        collectionView.delegate = self
        collectionView.registerNibCell(RecommendItemCell.self, forCellWithReuseIdentifier: "RecommendItemCell")
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    func bindUI(){
        listData.bind(to: collectionView.rx.items(cellIdentifier: "RecommendItemCell", cellType: RecommendItemCell.self)) { (row, element, cell) in
            cell.imageView.setImage(urlString: element.linkIcon, placeholder: "ic-discover-default")
            cell.titleLabel.text = element.linkName
         }
         .disposed(by: bag)
        
        collectionView.rx.modelSelected(Model.Discover.Item.self)
            .bind(to: didSelectedItem)
            .disposed(by: bag)
    }

}

extension DiscoverRecommendCell: UICollectionViewDelegate , UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 76, height: 117)
    }
    
    //在同一个Section中相邻两个item之间的间隙
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}



