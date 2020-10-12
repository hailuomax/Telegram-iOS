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
    
    var listData = PublishSubject<[Model.Discover.Dynamic.Item]>()
    
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUI()
        bindUI()
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
         .disposed(by: disposeBag)
    }

}

extension DiscoverRecommendCell: UICollectionViewDelegate , UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 75, height: 117)
    }
    
    //在同一个Section中相邻两个item之间的间隙
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}



