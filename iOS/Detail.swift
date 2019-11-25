import UIKit

final class Detail: View {
    private weak var scroll: Scroll!
    private weak var height: NSLayoutConstraint!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("gone")
    }
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        scroll.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        scroll.right.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        height = scroll.bottom.constraint(equalTo: scroll.top)
        height.isActive = true
        
        DispatchQueue.main.async { [weak self] in
            self?.refresh()
        }
        
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.order()
            self?.scroll.contentOffset.y = 0
        }
    }
    
    override func refresh() {
        scroll.views.forEach { $0.removeFromSuperview() }
        app.session.projects(app.main.bar.find.filter).enumerated().forEach {
            let item = Project($0.1, order: $0.0)
            scroll.add(item)
            item.top = item.topAnchor.constraint(equalTo: scroll.top)
            item.left = item.leftAnchor.constraint(equalTo: scroll.left)
        }
        order()
    }
    
//    override func viewDidEndLiveResize() {
//        super.viewDidEndLiveResize()
//        order()
//        NSAnimationContext.runAnimationGroup {
//            $0.duration = 0.4
//            $0.allowsImplicitAnimation = true
//            scroll.documentView!.layoutSubtreeIfNeeded()
//        }
//    }
    
    func order() {
        let size = superview!.safeAreaLayoutGuide.layoutFrame.width + 5
        let count = Int(size) / 180
        let margin = (size - (.init(count) * 180)) / 2
        var top = CGFloat(10)
        var left = margin
        var counter = 0
        scroll.views.map { $0 as! Project }.sorted { $0.order < $1.order }.forEach {
            if counter >= count {
                counter = 0
                left = margin
                top += 225
            }
            $0.top.constant = top
            $0.left.constant = left
            left += 180
            counter += 1
        }
        height.constant = top + 230
    }
}
