import UIKit

final class Move: Modal {
    private weak var card: Card?
    private weak var columns: Scroll!
    private weak var indexes: Scroll!
    private weak var _height: NSLayoutConstraint!
    private var column: Int
    private var index: Int
    private let height = CGFloat(200)
    private let inner = CGFloat(35)
    
    required init?(coder: NSCoder) { nil }
    init(_ card: Card) {
        column = card.column
        index = card.index
        super.init()
        self.card = card
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let columns = Scroll()
        view.addSubview(columns)
        self.columns = columns
        
        let indexes = Scroll()
        view.addSubview(indexes)
        self.indexes = indexes
        
        (0 ..< app.session.lists(app.project!)).forEach {
            let name = Label(app.session.name(app.project!, list: $0), 18, .medium, UIColor(named: "haze")!)
            columns.add(name)
            
            name.rightAnchor.constraint(equalTo: columns.right, constant: -20).isActive = true
            name.centerYAnchor.constraint(equalTo: columns.top, constant: (height / 2) + (.init($0) * inner)).isActive = true
        }
        
        columns.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        columns.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        columns.widthAnchor.constraint(equalToConstant: 150).isActive = true
        columns.heightAnchor.constraint(equalToConstant: height).isActive = true
        columns.width.constraint(equalToConstant: 150).isActive = true
        columns.height.constraint(equalToConstant: height + (.init(app.session.lists(app.project!)) * inner)).isActive = true
        
        indexes.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        indexes.leftAnchor.constraint(equalTo: columns.rightAnchor).isActive = true
        indexes.widthAnchor.constraint(equalToConstant: 100).isActive = true
        indexes.heightAnchor.constraint(equalToConstant: height).isActive = true
        indexes.width.constraint(equalToConstant: 100).isActive = true
        _height = indexes.height.constraint(equalToConstant: 0)
        _height.isActive = true
        
        reindex()
    }
    
    private func reindex() {
        indexes.views.forEach { $0.removeFromSuperview() }
        (0 ..< app.session.cards(app.project!, list: column)).forEach {
            let name = Label("\($0 + 1)", 18, .medium, UIColor(named: "haze")!)
            indexes.add(name)
            
            name.leftAnchor.constraint(equalTo: indexes.left).isActive = true
            name.centerYAnchor.constraint(equalTo: indexes.top, constant: (height / 2) + (.init($0) * inner)).isActive = true
        }
        _height.constant = height + (.init(app.session.cards(app.project!, list: column)) * inner)
    }
}
