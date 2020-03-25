//
//  JY+Refresher.swift 上下拉加载
//  TelegramUI
//
//  Created by 黄国坚 on 2019/10/29.
//  Copyright © 2019 Telegram. All rights reserved.
//

import UIKit
import ESPullToRefresh


/// 下拉刷新，上拉加载更多的状态值枚举
enum JYScrollViewRefreshType : Int{
    case refreshing
    case moreLoading
    case stopRefreshing
    case stopMoreLoading
    case stopNoMoreLoading
}

extension UIScrollView: JYNameSpace{}

///上拉加载更多，下拉刷新扩展
extension JY where Base : UIScrollView{
    
    ///下拉刷新
    func onRefresh(doIt : @escaping ()->()) {
        
        base.es.addPullToRefresh(animator: JYRefreshAnimator()) {
            
            doIt()
        }
    }
    
    ///上拉加载
    func onLoadMore(doIt : @escaping ()->()) {
        
        base.es.addInfiniteScrolling(animator: JYLoadMoreAnimator()) {[weak base] in
            guard let base = base else {return}
            if base.contentSize.height > 1 {//避免在空页面情况下自动或者手动下拉刷新
                doIt()
            }else{
                self.stopLoadMore(false)
            }
        }
    }
    
    ///主动刷新
    func startRefresh(){
        
        base.es.startPullToRefresh()
    }
    ///停止刷新
    func stopRefresh(){
        
        base.es.stopPullToRefresh()
    }
    ///停止加载
    func stopLoadMore(_ noMore : Bool){
        
        if noMore{ //没有更多数据时，显示
            base.es.noticeNoMoreData()
        }else{
            base.es.stopLoadingMore()
            base.es.resetNoMoreData()
        }
    }
}

///下拉刷新头部
fileprivate class JYRefreshAnimator: UIView, ESRefreshProtocol, ESRefreshAnimatorProtocol {
    
    public var insets: UIEdgeInsets = UIEdgeInsets.zero
    public var view: UIView { return self }
    public var trigger: CGFloat = 40
    public var executeIncremental: CGFloat = 40
    public var state: ESRefreshViewState = .pullToRefresh
    
    private var timer: Timer?
    private var timerProgress: Double = 0.0
    
    private let imageView: UIView = {
        
        let imageView = UIImageView(image: UIImage(named: "refresh/loading", in: Bundle(for: JYRefreshAnimator.self), compatibleWith: nil)).then{
            $0.sizeToFit()
            $0.isHidden = true
        }
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func refreshAnimationBegin(view: ESRefreshComponent) {
        
        guard let superV = self.superview else {return}
        let centerX = superV.bounds.size.width / 2.0
        let centerY = superV.bounds.size.height / 2.0
        imageView.center = {
            var tmpCenter = imageView.center
            tmpCenter.x = centerX
            tmpCenter.y = centerY
            return tmpCenter
        }()
        imageView.isHidden = false
        self.startAnimating()
    }
    
    public func refreshAnimationEnd(view: ESRefreshComponent) {
        
        guard let superV = self.superview else {return}
        
        let centerX = superV.bounds.size.width / 2.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            
            if view.isRefreshing {return}
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.imageView.center = CGPoint.init(x: centerX, y: -self.trigger)
            }) { (_) in
                self.stopAnimating()
                self.imageView.transform = CGAffineTransform.identity
            }
        })
    }
    
    public func refresh(view: ESRefreshComponent, progressDidChange progress: CGFloat) {
        
    }
    
    public func refresh(view: ESRefreshComponent, stateDidChange state: ESRefreshViewState) {
        guard self.state != state else {return}
        self.state = state
    }
    
    @objc func timerAction() {
        timerProgress += 0.01
        self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi) * CGFloat(timerProgress))
    }
    
    private func startAnimating() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
        }
    }
    
    private func stopAnimating() {
        if timer != nil {
            timerProgress = 0.0
            timer?.invalidate()
            timer = nil
        }
    }
}

///加载更多
fileprivate struct JYLoadMoreAnimator : ESRefreshProtocol , ESRefreshAnimatorProtocol{
    
    private let lb : UILabel = UILabel().then{
        $0.text = ""
        $0.font = UIFont.systemFont(ofSize: 10)
        $0.textAlignment = .center
        $0.textColor = UIColor.hex(.ka1a1a1)
    }
    
    var view: UIView {
        return lb
    }
    
    var insets: UIEdgeInsets = UIEdgeInsets.zero
    
    var trigger: CGFloat = 40
    
    var executeIncremental: CGFloat = 40
    
    var state: ESRefreshViewState = .pullToRefresh
  
    
    func refreshAnimationBegin(view: ESRefreshComponent) {
        
        guard let superV = lb.superview else {return}
        let size = superV.bounds.size
        lb.center = CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    func refreshAnimationEnd(view: ESRefreshComponent) {
        
    }
    
    func refresh(view: ESRefreshComponent, progressDidChange progress: CGFloat) {
        
    }
    
    func refresh(view: ESRefreshComponent, stateDidChange state: ESRefreshViewState) {
        
        var text : String!
        
        switch state {
            
        case .pullToRefresh:
            text = HL.Language.LoadMore.localized()
        case .releaseToRefresh:
            text = HL.Language.TryingToLoad.localized()
        case .refreshing:
            text = HL.Language.TryingToLoad.localized()
        case .autoRefreshing:
            text = HL.Language.TryingToLoad.localized()
        case .noMoreData:
            text = HL.Language.ThereAreOnlySoMany.localized()
        }
        
        lb.do{
            $0.text = text
            $0.sizeToFit()
        }
    }
}
