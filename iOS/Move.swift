import UIKit

final class Move: UIViewController, UIScrollViewDelegate {
    private weak var card: Card?
    private weak var columns: Scroll!
    private weak var indexes: Scroll!
    private weak var _height: NSLayoutConstraint!
    private weak var bottom: NSLayoutConstraint!
    private var column: Int
    private var index: Int
    private let height = CGFloat(250)
    private let inner = CGFloat(40)
    
    required init?(coder: NSCoder) { nil }
    init(_ card: Card) {
        column = card.column
        index = card.index
        super.init(nibName: nil, bundle: nil)
        self.card = card
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .init(white: 0, alpha: 0.4)
        
        let gradient = Gradient()
        gradient.layer.cornerRadius = 8
        gradient.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview(gradient)
        
        let columns = Scroll()
        columns.delegate = self
        columns.contentInsetAdjustmentBehavior = .never
        view.addSubview(columns)
        self.columns = columns
        
        let indexes = Scroll()
        indexes.delegate = self
        indexes.contentInsetAdjustmentBehavior = .never
        view.addSubview(indexes)
        self.indexes = indexes
        
        (0 ..< app.session.lists(app.project!)).forEach {
            let name = Label(app.session.name(app.project!, list: $0), 16, .medium, UIColor(named: "haze")!)
            name.tag = $0
            name.alpha = $0 == column ? 1 : 0.3
            columns.add(name)
            
            name.rightAnchor.constraint(equalTo: columns.right, constant: -40).isActive = true
            name.centerYAnchor.constraint(equalTo: columns.top, constant: (height / 2) + (.init($0) * inner)).isActive = true
        }
        
        gradient.heightAnchor.constraint(equalToConstant: height).isActive = true
        gradient.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        gradient.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bottom = gradient.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: height)
        bottom.isActive = true
        
        columns.bottomAnchor.constraint(equalTo: gradient.bottomAnchor).isActive = true
        columns.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        columns.widthAnchor.constraint(equalToConstant: 150).isActive = true
        columns.heightAnchor.constraint(equalToConstant: height).isActive = true
        columns.width.constraint(equalToConstant: 150).isActive = true
        columns.height.constraint(equalToConstant: height + (.init(app.session.lists(app.project!) - 1) * inner)).isActive = true
        
        indexes.bottomAnchor.constraint(equalTo: gradient.bottomAnchor).isActive = true
        indexes.leftAnchor.constraint(equalTo: columns.rightAnchor).isActive = true
        indexes.widthAnchor.constraint(equalToConstant: 100).isActive = true
        indexes.heightAnchor.constraint(equalToConstant: height).isActive = true
        indexes.width.constraint(equalToConstant: 100).isActive = true
        _height = indexes.height.constraint(equalToConstant: 0)
        _height.isActive = true
        
        reindex()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bottom.constant = 0
        columns.contentOffset.y = .init(column) * inner
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bottom.constant = height
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.card?.backgroundColor = .clear
            self?.view.layoutIfNeeded()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        if touches.first!.location(in: view).y < view.bounds.height - height {
            close()
        }
        super.touchesEnded(touches, with: with)
    }
    
    func scrollViewDidScroll(_ scroll: UIScrollView) {
        guard let card = self.card else { return }
        var tag = max(Int((scroll.contentOffset.y + (inner / 2)) / inner), 0)
        if scroll === indexes {
            tag = min(tag, app.session.cards(app.project!, list: column) - (column == card.column ? 1 : 0))
            index = tag
        } else {
            tag = min(tag, app.session.lists(app.project!) - 1)
            column = tag
            index = 0
            reindex()
        }
        (scroll as! Scroll).views.forEach {
            $0.alpha = $0.tag == tag ? 1 : 0.3
        }
    }
    
    private func reindex() {
        guard let card = self.card else { return }
        let index = self.index
        let inner = self.inner
        indexes.views.forEach { $0.removeFromSuperview() }
        (0 ..< app.session.cards(app.project!, list: column) + (column == card.column ? 0 : 1)).forEach {
            let name = Label("\($0 + 1)", 16, .medium, UIColor(named: "haze")!)
            name.tag = $0
            name.alpha = $0 == index ? 1 : 0.3
            indexes.add(name)
            
            name.leftAnchor.constraint(equalTo: indexes.left).isActive = true
            name.centerYAnchor.constraint(equalTo: indexes.top, constant: (height / 2) + (.init($0) * inner)).isActive = true
        }
        _height.constant = height + (.init(app.session.cards(app.project!, list: column) - (column == card.column ? 1 : 0)) * inner)
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.indexes.contentOffset.y = .init(index) * inner
        }
    }
    
    @objc private func close() {
        presentingViewController!.dismiss(animated: true)
    }
}
