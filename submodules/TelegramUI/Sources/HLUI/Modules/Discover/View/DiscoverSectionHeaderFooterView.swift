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

class DiscoverSectionHeaderView : UICollectionReusableView {
    
    lazy var contentView = UIView()
    
    lazy var titleLabel = UILabel()

    lazy var moreButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(contentView)
        contentView.backgroundColor = .white
        contentView.frame = CGRect(x: kSectionEdge.left, y: kSectionEdge.top, width: kScreenWidth - kSectionEdge.left - kSectionEdge.right, height: 50)
        contentView.setMaskCorner(roundingCorners: [.topLeft, .topRight], cornerSize: CGSize(width: 7.5, height: 7.5))
        
        setSubViews()
    }
    
    func setSubViews(){
        titleLabel.font = CustomFont.mediumFontWithSize(16)
        moreButton.setTitleColor(UIColor(hexString: "AEB2C3"), for: .normal)
        moreButton.setImage(UIImage(bundleImageName: "arrowGrayRight"), for: .normal)
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(moreButton)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.centerY.equalToSuperview()
        }
        
        moreButton.snp.makeConstraints { (make) in
            make.right.equalTo(-12)
            make.centerY.equalToSuperview()
        }
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
        contentView.frame = CGRect(x: kSectionEdge.left, y: 0, width: kScreenWidth - kSectionEdge.left - kSectionEdge.right, height: 20)
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
        //注册我们自定义用来作为Section背景的 Decoration 视图
        self.register(SectionBgCollectionReusableView.classForCoder(),
                      forDecorationViewOfKind: SectionBg)
    }
    
    override func prepare() {
        super.prepare()
        //如果collectionView当前没有分区，或者未实现相关的代理则直接退出
        guard let numberOfSections = self.collectionView?.numberOfSections
            else {
                return
        }
        
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
            sectionFrame.size.width = self.collectionView!.frame.width - kSectionEdge.left - kSectionEdge.right
            sectionFrame.size.height += sectionInset.top + sectionInset.bottom
            
            
            //更具上面的结果计算section背景的布局属性
            let attr = SectionBgCollectionViewLayoutAttributes(forDecorationViewOfKind: SectionBg,
                                                               with: IndexPath(item: 0, section: section))
            attr.frame = sectionFrame
            attr.zIndex = -1
            //通过代理方法获取该section背景使用的颜色
            attr.backgroundColor = section == 0 ? .clear : .white
            
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
        
    //背景色
    var backgroundColor = UIColor.white
    
    //所定义属性的类型需要遵从 NSCopying 协议
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! SectionBgCollectionViewLayoutAttributes
        copy.backgroundColor = self.backgroundColor
        return copy
    }
    
    //所定义属性的类型还要实现相等判断方法（isEqual）
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
