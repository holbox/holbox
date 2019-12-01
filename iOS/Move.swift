import UIKit

final class Move: UIViewController, UIScrollViewDelegate {
    private weak var card: Card?
    private weak var columns: Scroll!
    private weak var indexes: Scroll!
    private weak var _height: NSLayoutConstraint!
    private weak var bottom: NSLayoutConstraint!
    private var column: Int
    private var index: Int
    private let height = CGFloat(150)
    private let inner = CGFloat(26)
    
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
        
        let base = UIView()
        base.isUserInteractionEnabled = false
        base.translatesAutoresizingMaskIntoConstraints = false
        base.backgroundColor = UIColor(named: "background")!
        base.layer.cornerRadius = 8
        base.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview(base)
        
        let indexes = Scroll()
        indexes.delegate = self
        indexes.contentInsetAdjustmentBehavior = .never
        view.addSubview(indexes)
        self.indexes = indexes
        
        let columns = Scroll()
        columns.delegate = self
        columns.contentInsetAdjustmentBehavior = .never
        view.addSubview(columns)
        self.columns = columns
        
        let title = Label(.key("Move.title"), 14, .regular, UIColor(named: "haze")!)
        view.addSubview(title)
        
        (0 ..< app.session.lists(app.project!)).forEach {
            let name = Label(app.session.name(app.project!, list: $0), 18, .bold, UIColor(named: "haze")!)
            name.tag = $0
            name.alpha = $0 == column ? 1 : 0.3
            columns.add(name)
            
            name.rightAnchor.constraint(equalTo: columns.right, constant: -40).isActive = true
            name.centerYAnchor.constraint(equalTo: columns.top, constant: (height / 2) + (.init($0) * inner)).isActive = true
        }
        
        base.heightAnchor.constraint(equalToConstant: height).isActive = true
        base.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bottom = base.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: height)
        bottom.isActive = true
        
        columns.bottomAnchor.constraint(equalTo: base.bottomAnchor).isActive = true
        columns.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        columns.heightAnchor.constraint(equalToConstant: height).isActive = true
        columns.rightAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        columns.right.constraint(equalTo: view.centerXAnchor).isActive = true
        columns.height.constraint(equalToConstant: height + (.init(app.session.lists(app.project!) - 1) * inner)).isActive = true
        
        indexes.alwaysBounceHorizontal = false
        indexes.bottomAnchor.constraint(equalTo: base.bottomAnchor).isActive = true
        indexes.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        indexes.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        indexes.heightAnchor.constraint(equalToConstant: height).isActive = true
        indexes.right.constraint(equalTo: view.rightAnchor).isActive = true
        _height = indexes.height.constraint(equalToConstant: 0)
        _height.isActive = true
        
        title.centerYAnchor.constraint(equalTo: base.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: base.centerXAnchor, constant: 100).isActive = true
        
        reindex()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bottom.constant = 1
        columns.contentOffset.y = .init(column) * inner
        UIView.animate(withDuration: 0.35) { [weak self] in
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
        var change = false
        var tag = max(Int((scroll.contentOffset.y + (inner / 2)) / inner), 0)
        if scroll === indexes {
            tag = min(tag, app.session.cards(app.project!, list: column) - (column == card.column ? 1 : 0))
            if tag != index {
                change = true
                index = tag
            }
        } else {
            tag = min(tag, app.session.lists(app.project!) - 1)
            if column != tag {
                change = true
                column = tag
                index = min(index, app.session.cards(app.project!, list: column) - (column == card.column ? 1 : 0))
                reindex()
            }
        }
        if change {
            (scroll as! Scroll).views.forEach {
                $0.alpha = $0.tag == tag ? 1 : 0.3
            }
        }
    }
    
    private func reindex() {
        guard let card = self.card else { return }
        let index = self.index
        let inner = self.inner
        indexes.views.forEach { $0.removeFromSuperview() }
        (0 ..< app.session.cards(app.project!, list: column) + (column == card.column ? 0 : 1)).forEach {
            let name = Label("\($0 + 1)", 18, .bold, UIColor(named: "haze")!)
            name.tag = $0
            name.alpha = $0 == index ? 1 : 0.3
            indexes.add(name)
            
            name.leftAnchor.constraint(equalTo: indexes.centerX).isActive = true
            name.centerYAnchor.constraint(equalTo: indexes.top, constant: (height / 2) + (.init($0) * inner)).isActive = true
        }
        _height.constant = height + (.init(app.session.cards(app.project!, list: column) - (column == card.column ? 1 : 0)) * inner)
        indexes.layoutIfNeeded()
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.indexes.contentOffset.y = .init(index) * inner
        }
    }
    
    @objc private func close() {
        presentingViewController!.dismiss(animated: true)
    }
}
