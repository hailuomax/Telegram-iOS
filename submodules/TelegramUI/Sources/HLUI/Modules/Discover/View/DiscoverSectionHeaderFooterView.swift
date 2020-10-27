//
//  DiscoverSectionHeaderFooterView.swift
//  TelegramUI#shared
//
//  Created by fan on 2020/10/9.
//

import UIKit
import Extension
import Config
import HL
import RxSwift

class DiscoverSectionHeaderView : UICollectionReusableView {
    
    lazy var contentView = UIView()
    
    lazy var titleLabel = UILabel()

    lazy var moreButton = UIButton()
    
    var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(contentView)
        contentView.backgroundColor = .white
        contentView.frame = CGRect(x: kSectionEdge.left, y: kSectionEdge.top, width: kScreenWidth - kSectionEdge.left - kSectionEdge.right, height: 50)
        contentView.setMaskCorner(roundingCorners: [.topLeft, .topRight], cornerSize: CGSize(width: 7.5, height: 7.5))
        
        setSubViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func setSubViews(){
        titleLabel.font = CustomFont.mediumFontWithSize(16)
        moreButton.setTitleColor(UIColor(hexString: "AEB2C3"), for: .normal)
        moreButton.setImage(UIImage(bundleImageName: "arrowGrayRight"), for: .normal)
        moreButton.titleLabel?.font = CustomFont.regularfontWithSize(13)
        moreButton.setTitle("查看全部", for: .normal)
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(moreButton)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.centerY.equalToSuperview()
        }
        
        moreButton.snp.makeConstraints { (make) in
            make.right.equalTo(-12)
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(70)
        }
        
        moreButton.layoutButtonEdgeInsets(type: .PositionRight, space: 8)
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class DiscoverSectionFooterView: UICollectionReusableView {
    lazy var contentView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(contentView)
        contentView.backgroundColor = .white
        contentView.frame = CGRect(x: kSectionEdge.left, y: 0, width: kScreenWidth - kSectionEdge.left - kSectionEdge.right, height: 10)
        contentView.setMaskCorner(roundingCorners: [.bottomLeft, .bottomRight], cornerSize: CGSize(width: 7.5, height: 7.5))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class SectionBackGroundColorLayout: UICollectionViewFlowLayout {
    
    private var decorationViewAttrs: [UICollectionViewLayoutAttributes] = []
    
    override init() {
        super.init()
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    //初始化时进行一些注册操作
    func setup() {
        self.register(SectionBgCollectionReusableView.classForCoder(),
                      forDecorationViewOfKind: SectionBg)
    }
    
    override func prepare() {
        super.prepare()
        decorationViewAttrs.removeAll()
        guard let numberOfSections = self.collectionView?.numberOfSections ,
              let delegate = self.collectionView?.delegate as? UICollectionViewDelegateFlowLayout
              else {return}
        
        //分别计算每个section背景的布局属性
        for section in 0..<numberOfSections {
            //获取该section下第一个，以及最后一个item的布局属性
            guard let numberOfItems = self.collectionView?.numberOfItems(inSection:section),
                  numberOfItems > 0,
                  let firstItem = self.layoutAttributesForItem(at:IndexPath(item: 0, section: section)),
                  let lastItem = self.layoutAttributesForItem(at:IndexPath(item: numberOfItems - 1, section: section))
            else {
                continue
            }
            
            //获取该section的内边距
            var sectionInset = self.sectionInset
            
            //计算得到该section实际的位置
            var sectionFrame = firstItem.frame.union(lastItem.frame)
            sectionFrame.origin.x = kSectionEdge.left
            sectionFrame.origin.y -= sectionInset.top
            
            //计算得到该section实际的尺寸
            sectionFrame.size.width = kScreenWidth - kSectionEdge.left - kSectionEdge.right
//            sectionFrame.size.height += sectionInset.top + sectionInset.bottom
            
            
            //更具上面的结果计算section背景的布局属性
            let attr = SectionBgCollectionViewLayoutAttributes(forDecorationViewOfKind: SectionBg,
                                                               with: IndexPath(item: 0, section: section))
            attr.frame = sectionFrame
            attr.zIndex = -1
            //通过代理方法获取该section背景使用的颜色
            attr.backgroundColor = delegate.collectionView?(self.collectionView!, layout: self.collectionView!.collectionViewLayout, referenceSizeForHeaderInSection: section).equalTo(CGSize.zero) ?? true ? .clear : .white
            
            //将该section背景的布局属性保存起来
            self.decorationViewAttrs.append(attr)
        }
    }
    
    //返回rect范围下所有元素的布局属性（这里我们将自定义的section背景视图的布局属性也一起返回）
    override func layoutAttributesForElements(in rect: CGRect)
    -> [UICollectionViewLayoutAttributes]? {
        var attrs = super.layoutAttributesForElements(in: rect)
        attrs?.append(contentsOf: self.decorationViewAttrs.filter {
            return rect.intersects($0.frame)
        })
        return attrs
    }
    
    //返回对应于indexPath的位置的Decoration视图的布局属性
    override func layoutAttributesForDecorationView(ofKind elementKind: String,
                at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        //如果是我们自定义的Decoration视图（section背景），则返回它的布局属性
        if elementKind == SectionBg {
            return self.decorationViewAttrs[indexPath.section]
        }
        return super.layoutAttributesForDecorationView(ofKind: elementKind,
                                                       at: indexPath)
    }
}
    
private let SectionBg = "SectionBgCollectionReusableView"

//继承UICollectionReusableView来自定义一个装饰视图（Decoration 视图）,用来作为Section背景
private class SectionBgCollectionReusableView: UICollectionReusableView {
     
    //通过apply方法让自定义属性生效
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
         
        guard let attr = layoutAttributes as? SectionBgCollectionViewLayoutAttributes else
        {
            return
        }
         
        self.backgroundColor = attr.backgroundColor
    }
}

//定义一个UICollectionViewLayoutAttributes子类作为section背景的布局属性，
//（在这里定义一个backgroundColor属性表示Section背景色）
private class SectionBgCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
        
    
    var backgroundColor = UIColor.white
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! SectionBgCollectionViewLayoutAttributes
        copy.backgroundColor = self.backgroundColor
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? SectionBgCollectionViewLayoutAttributes else {
            return false
        }
        
        if !self.backgroundColor.isEqual(rhs.backgroundColor) {
            return false
        }
        return super.isEqual(object)
    }
}
