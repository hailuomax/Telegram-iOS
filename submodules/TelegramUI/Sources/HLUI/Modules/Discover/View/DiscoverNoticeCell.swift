//
//  DiscoverNoticeCell.swift
//  TelegramUI#shared
//
//  Created by fan on 2020/10/9.
//

import UIKit
import Model
import Extension
import UI
import RxSwift
import RxCocoa

class DiscoverNoticeCell: UICollectionViewCell {
    
    @IBOutlet var bgView: VerticalBannerView!
    
    private let disposeBag = DisposeBag()
    
    var cellBag = DisposeBag()
    
    let didSelectedItem = PublishSubject<Model.Discover.SysMessage.Item>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellBag = DisposeBag()
    }
    
    func setUI(){
        self.cornerRadius = 7.5
    }

    func setList(list: [Model.Discover.SysMessage.Item]) {
        bgView.repeatShow(dataSources: list, repetitionInterval: 3, withDuration: 0.3) {[weak self] (item) -> (UIView) in
            let button = NoticeButton()
            button.titleLabel?.textAlignment = .left
            button.contentHorizontalAlignment = .left
            button.titleLabel?.lineBreakMode = .byTruncatingTail
            button.titleLabel?.font = FontEnum.k_pingFangSC_Medium.toFont(12)
            button.setTitleColor(UIColor(hexString: "#9AA3AC"), for: .normal)
            button.setTitle(item.content, for: .normal)
            if let self = self {
                button.rx.controlEvent(.touchUpInside)
                    .map{_ in item}
                    .bind(to: self.didSelectedItem)
                    .disposed(by: button.disposeBag)
            }
            return button
        }
    }
}

private class NoticeButton : UIButton {
    
     let disposeBag = DisposeBag()
}
