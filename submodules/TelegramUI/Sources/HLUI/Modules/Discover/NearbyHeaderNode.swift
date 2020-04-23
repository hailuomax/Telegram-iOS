//
//  NearbyHeaderNode.swift
//  TelegramUI
//
//  Created by lemon on 2020/3/26.
//  Copyright © 2020 Telegram. All rights reserved.
//

import Display
import AsyncDisplayKit
import TelegramPresentationData

//MARK: --NearbyHeaderNode
class NearbyHeaderNode : ASDisplayNode {
    
    private let titleNode: ASTextNode
//    private var iconNode: PeersNearbyIconNode
    private let iconNode : ASDisplayNode
    private lazy var iconImageView = UIImageView(image: UIImage(bundleImageName: "nearby_icon"))
    private let animationView : RippleAnimationView
    
    init(theme : PresentationTheme , text: String) {
        self.titleNode = ASTextNode()
        self.titleNode.isUserInteractionEnabled = false
        self.titleNode.contentsScale = UIScreen.main.scale
        self.iconNode = ASDisplayNode()
        self.animationView = RippleAnimationView()
        super.init()
        
        self.addSubnode(self.titleNode)
//        self.addSubnode(self.iconNode)
        self.view.addSubview(animationView)
        self.view.addSubview(iconImageView)
        self.backgroundColor = theme.list.plainBackgroundColor

        let attributedText =  NSAttributedString(string: text, font: Font.regular(13.0), textColor: theme.list.freeTextColor, paragraphAlignment: .center)
        iconNode.backgroundColor = .white
        titleNode.attributedText = attributedText
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let width = constrainedSize.max.width
        let iconSize = CGSize(width: 80, height: 40)

        let iconNodeWidth = iconSize.width + 10
        
        animationView.frame = CGRect(x: floor((width - iconSize.width) / 2.0), y: 20, width: iconNodeWidth, height: iconNodeWidth)
        iconImageView.frame.size = CGSize(width: 40, height: 40)
        iconImageView.center = animationView.center
        animationView.startAnimate()
        titleNode.style.layoutPosition = CGPoint(x: 30, y: 120)
        titleNode.style.preferredSize = CGSize(width: width - 60, height: 40)
        return ASLayoutSpec().then{$0.children = [titleNode]}
//        return ASLayoutSpec.init(children: [titleNode])
    }
    


    
}

class RippleAnimationView : UIView {
    
    // 设置静态常量 pulsingCount ，表示 Layer 的数量
    var pulsingCount : Int = 3

    // animationDuration ，表示动画时间
    var animationDuration : Double  =  2
    
    // 扩散圆弧半径
    var anumationRadius : CGFloat = 30
    
    // 扩散比例
    var multiple : CGFloat = 1.6
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func startAnimate() {
        let animationLayer = CALayer()
        for i in 0..<pulsingCount {
            let animations : [CAAnimation] = [scaleAnimation() ,lineColorAnimation()]
            let group = animationGroup(animations: animations, index: i)
            let pulsingLayer = self.pulsingLayer(rect: self.frame, animation: group)
            animationLayer.addSublayer(pulsingLayer)
        }
        self.layer.addSublayer(animationLayer)
    }
    
    //缩放动画
    func scaleAnimation() -> CABasicAnimation{
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1
        scaleAnimation.toValue = multiple
//        scaleAnimation.beginTime = CACurrentMediaTime()
//        scaleAnimation.duration = CFTimeInterval(animationDuration)
        return scaleAnimation
    }
    
    func lineColorAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "strokeColor"
        animation.values = [UIColor(red: 64/255.0, green: 164/255.0, blue: 1, alpha: 1).cgColor ,UIColor(red: 64/255.0, green: 164/255.0, blue: 1, alpha: 0.6).cgColor , UIColor(red: 64/255.0, green: 164/255.0, blue: 1, alpha: 0).cgColor   ]
        animation.keyTimes = [0.3, 0.6 ,0.9]
//        animation.duration = CFTimeInterval(animationDuration)
        return animation
    }
    
    func pulsingLayer(rect: CGRect, animation: CAAnimation) -> CALayer {
        let layerRect = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
        let lineWidth : CGFloat = 2
        let bezierPath = UIBezierPath()
        // 线高度
        let lineHeight : CGFloat = 23
        let rightBP = UIBezierPath()
        let rightPoint = CGPoint(x: rect.width / 2 + anumationRadius, y: (rect.height - lineHeight) / 2)
        rightBP.move(to: rightPoint)
        rightBP.addQuadCurve(to: CGPoint(x: rightPoint.x, y: rightPoint.y + lineHeight), controlPoint: CGPoint(x: rightPoint.x + 5, y: rightPoint.y + (lineHeight / 2)))

        rightBP.lineCapStyle = .round
        bezierPath.append(rightBP)
        
        let leftBP = UIBezierPath()
        let leftPoint = CGPoint(x: rect.width / 2 - anumationRadius, y: rightPoint.y)
        leftBP.move(to: leftPoint)
        leftBP.addQuadCurve(to: CGPoint(x: leftPoint.x, y:  leftPoint.y + lineHeight), controlPoint: CGPoint(x: leftPoint.x - 5, y:  rightPoint.y + (lineHeight / 2)))
        leftBP.lineCapStyle = .round
        bezierPath.append(leftBP)
        
        //因为绘图不在drawRect:方法中操作导致绘图时没有当前的图形上下文(context)可设置，需要获取上下文来绘制
        UIGraphicsBeginImageContext(bounds.size)
        bezierPath.fill()
        UIGraphicsEndImageContext()
        
        let returnLayer = CAShapeLayer()
        returnLayer.path = bezierPath.cgPath
        returnLayer.fillColor = UIColor.clear.cgColor
        returnLayer.lineWidth = lineWidth
        returnLayer.lineCap = .round
        returnLayer.frame = layerRect
        returnLayer.add(animation, forKey: "plulsing")
        return returnLayer
    }
    
    func animationGroup(animations: [CAAnimation], index: Int) -> CAAnimationGroup{
        let group = CAAnimationGroup()
        group.animations = animations
        group.beginTime = CACurrentMediaTime() + Double(index ) * animationDuration / Double(pulsingCount)
        group.duration = CFTimeInterval(animationDuration)
        group.repeatCount = HUGE
        group.isRemovedOnCompletion = false
        group.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.default)
        return group
    }
    
}
