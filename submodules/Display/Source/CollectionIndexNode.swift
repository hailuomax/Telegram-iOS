import Foundation
import UIKit
import AsyncDisplayKit

private let titleFont = Font.bold(11.0)

public final class CollectionIndexNode: ASDisplayNode {
    public static let searchIndex: String = "_$search$_"
    
    private var currentSize: CGSize?
    private var currentSections: [String] = []
    private var currentColor: UIColor?
    private var titleNodes: [String: (node: HLIndexItemNode, size: CGSize)] = [:]
    private var scrollFeedback: HapticFeedback?
    
    private var currentSelectedIndex: String?
    public var indexSelected: ((String) -> Void)?
    //大标题提示Node
    private let bigTitleNode: BigTitleNode
    
    override public init() {
        bigTitleNode = BigTitleNode()
        super.init()
        bigTitleNode.isHidden = true
        bigTitleNode.frame = CGRect(x: 0, y: 0, width: 37, height: 37)
        self.addSubnode(bigTitleNode)
        
    }
    
    override public func didLoad() {
        super.didLoad()
        
        self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.panGesture(_:))))
    }
    
    public func update(size: CGSize, color: UIColor, sections: [String], transition: ContainedViewLayoutTransition) {
        if self.currentColor == nil || !color.isEqual(self.currentColor) {
            self.currentColor = color
            for (title, nodeAndSize) in self.titleNodes {
                nodeAndSize.node.textNode.attributedText = NSAttributedString(string: title, font: titleFont, textColor: color)
                let _ = nodeAndSize.node.updateLayout(CGSize(width: 100.0, height: 100.0))
            }
        }
        
        if self.currentSize == size && self.currentSections == sections {
            return
        }
        
        self.currentSize = size
        self.currentSections = sections
        
        let itemHeight: CGFloat = 15.0
        let verticalInset: CGFloat = 10.0
        let maxHeight = size.height - verticalInset * 2.0
        
        let maxItemCount = min(sections.count, Int(floor(maxHeight / itemHeight)))
        let skipCount: Int
        if sections.isEmpty {
            skipCount = 1
        } else {
            skipCount = Int(ceil(CGFloat(sections.count) / CGFloat(maxItemCount)))
        }
        let actualCount: CGFloat = ceil(CGFloat(sections.count) / CGFloat(skipCount))
        
        let totalHeight = actualCount * itemHeight
        let verticalOrigin = verticalInset + floor((maxHeight - totalHeight) / 2.0)
        
        var validTitles = Set<String>()
        
        var currentIndex = 0
        var displayIndex = 0
        var addedLastTitle = false
        
        let addTitle: (Int) -> Void = { index in
            let title = sections[index]
            let nodeAndSize: (node: HLIndexItemNode, size: CGSize)
            var animate = false
            if let current = self.titleNodes[title] {
                animate = true
                nodeAndSize = current
            } else {
                let node = HLIndexItemNode()
                node.textNode.attributedText = NSAttributedString(string: title, font: titleFont, textColor: color)
                let nodeSize = node.updateLayout(CGSize(width: 100.0, height: 100.0))
                nodeAndSize = (node, nodeSize)
                self.addSubnode(node)
                self.titleNodes[title] = nodeAndSize
            }
            validTitles.insert(title)
            let previousPosition = nodeAndSize.node.position
            nodeAndSize.node.frame = CGRect(origin: CGPoint(x: floorToScreenPixels((size.width - nodeAndSize.size.width) / 2.0), y: verticalOrigin + itemHeight * CGFloat(displayIndex) + floor((itemHeight - nodeAndSize.size.height) / 2.0)), size: nodeAndSize.size)
            if animate {
                transition.animatePosition(node: nodeAndSize.node, from: previousPosition)
            }
            
            currentIndex += skipCount
            displayIndex += 1
        }
        
        while currentIndex < sections.count {
            if currentIndex == sections.count - 1 {
                addedLastTitle = true
            }
            addTitle(currentIndex)
        }
        
        if !addedLastTitle && sections.count > 0 {
            addTitle(sections.count - 1)
        }
        
        var removeTitles: [String] = []
        for title in self.titleNodes.keys {
            if !validTitles.contains(title) {
                removeTitles.append(title)
            }
        }
        
        for title in removeTitles {
            self.titleNodes.removeValue(forKey: title)?.node.removeFromSupernode()
        }
    }
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.isUserInteractionEnabled, self.bounds.insetBy(dx: -5.0, dy: 0.0).contains(point) {
            return self.view
        } else {
            return nil
        }
    }
    
    @objc private func panGesture(_ recognizer: UIPanGestureRecognizer) {
        var locationTitleAndPosition: (String, CGFloat)?
        let location = recognizer.location(in: self.view)
        var currentTitle : String = ""
        var currentNodeFrame : CGRect?
        for (title, nodeAndSize) in self.titleNodes {
            let nodeFrame = nodeAndSize.node.frame
            if location.y >= nodeFrame.minY - 5.0 && location.y <= nodeFrame.maxY + 5.0 {
                if let currentTitleAndPosition = locationTitleAndPosition {
                    let distance = abs(nodeFrame.midY - location.y)
                    let previousDistance = abs(currentTitleAndPosition.1 - location.y)
                    if distance < previousDistance {
                        locationTitleAndPosition = (title, nodeFrame.midY)
                    }
                } else {
                    locationTitleAndPosition = (title, nodeFrame.midY)
                }
                currentTitle = title
                currentNodeFrame = nodeFrame
            }
        }
        updateCurrentSelected(title: currentTitle)
        updateBigTitleNode(nodeFrame: currentNodeFrame, title: currentTitle)
        
        let locationTitle = locationTitleAndPosition?.0
        switch recognizer.state {
            case .began:
                self.currentSelectedIndex = locationTitle
                if let locationTitle = locationTitle {
                    self.indexSelected?(locationTitle)
                }
            case .changed:
                if locationTitle != self.currentSelectedIndex {
                    self.currentSelectedIndex = locationTitle
                    if let locationTitle = locationTitle {
                        self.indexSelected?(locationTitle)
                        
                        if self.scrollFeedback == nil {
                            self.scrollFeedback = HapticFeedback()
                        }
                        self.scrollFeedback?.tap()
                    }
                }
            case .cancelled, .ended:
                self.currentSelectedIndex = nil
                self.bigTitleNode.isHidden = true
            default:
                break
        }
    }
    /// 手动更新选择分区
    public func updateCurrentSelected(title: String?) {
        guard let updateTitle = title else {return}
        for (title, nodeAndSize) in self.titleNodes {
            if title == updateTitle {
                nodeAndSize.node.textNode.attributedText =  NSAttributedString(string: title, font: titleFont, textColor: .white)
                nodeAndSize.node.isHighlight = true
            }else {
                nodeAndSize.node.textNode.attributedText =  NSAttributedString(string: title, font: titleFont, textColor: currentColor!)
                nodeAndSize.node.isHighlight = false
            }
            nodeAndSize.node.updateLayout(nodeAndSize.size)
        }
    }
    /// 更新没有选中
    public func updateNotSelected() {
        for (title, nodeAndSize) in self.titleNodes {
            nodeAndSize.node.textNode.attributedText =  NSAttributedString(string: title, font: titleFont, textColor: currentColor!)
            nodeAndSize.node.isHighlight = false
            nodeAndSize.node.updateLayout(nodeAndSize.size)
        }
    }
    /// 更新大标题
    func updateBigTitleNode(nodeFrame: CGRect?, title: String?) {
        guard let currentFrame = nodeFrame, let currentTitle = title else {
            self.bigTitleNode.isHidden = true
            return
        }
        bigTitleNode.frame = CGRect(x: -37, y: currentFrame.midY - 37, width: 37, height: 37)
        bigTitleNode.titleNode.attributedText = NSAttributedString.init(string: currentTitle, attributes: [NSAttributedString.Key.font : Font.medium(26), NSAttributedString.Key.foregroundColor: UIColor.white])
        bigTitleNode.isHidden = false
    }

}

//大标题
class BigTitleNode : ASDisplayNode {
    
    lazy var titleNode : ASTextNode = ASTextNode()
    
    lazy var bgImageNode : ASImageNode = ASImageNode()
    
    override init() {
        super.init()
        titleNode.textAlignment = .center
        self.addSubnode(titleNode)
        self.bgImageNode.image = UIImage(bundleImageName: "title_bg")
//        self.bgImageNode.backgroundColor = UIColor(hexString: "949494")
        self.insertSubnode(bgImageNode, belowSubnode: titleNode)
    }
    
    override func didLoad() {
        super.didLoad()
        var titleNodeFrame = self.bounds
        titleNodeFrame.origin.y += 3
        titleNode.frame = titleNodeFrame
        bgImageNode.frame = self.bounds
    }
}
