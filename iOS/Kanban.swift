import UIKit

final class Kanban: View {
    private(set) weak var scroll: Scroll!
    private(set) weak var _add: Button!
    private(set) weak var tags: Tags!
    private weak var count: Label!
    private weak var bars: Bars!
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let tags = Tags()
        scroll.add(tags)
        self.tags = tags
        
        let _add = Button("plus", target: self, action: #selector(add))
        _add.accessibilityLabel = .key("Kanban.add")
        scroll.add(_add)
        self._add = _add
        
        let count = Label([])
        scroll.add(count)
        self.count = count

        let bars = Bars()
        scroll.add(bars)
        self.bars = bars
        
        let _column = Control(.key("Kanban.column"), self, #selector(column), .haze(0.2), .haze())
        scroll.add(_column)
        
        let _csv = Control(.key("Kanban.csv"), self, #selector(csv), .haze(0.2), .haze())
        scroll.add(_csv)

        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scroll.width.constraint(greaterThanOrEqualTo: widthAnchor).isActive = true
        scroll.height.constraint(greaterThanOrEqualTo: heightAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: tags.bottomAnchor, constant: 20).isActive = true
        
        tags.leftAnchor.constraint(equalTo: scroll.left, constant: 20).isActive = true
        tags.widthAnchor.constraint(greaterThanOrEqualTo: bars.widthAnchor, constant: 20).isActive = true
        tags.widthAnchor.constraint(greaterThanOrEqualTo: _column.widthAnchor, constant: 20).isActive = true
        tags.topAnchor.constraint(equalTo: _csv.bottomAnchor, constant: 30).isActive = true
        
        _column.widthAnchor.constraint(equalToConstant: 100).isActive = true
        _column.leftAnchor.constraint(equalTo: scroll.left, constant: 15).isActive = true
        _column.topAnchor.constraint(equalTo: count.bottomAnchor, constant: 20).isActive = true
        
        _csv.widthAnchor.constraint(equalToConstant: 100).isActive = true
        _csv.leftAnchor.constraint(equalTo: scroll.left, constant: 15).isActive = true
        _csv.topAnchor.constraint(equalTo: _column.bottomAnchor).isActive = true
        
        _add.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        count.topAnchor.constraint(equalTo: bars.bottomAnchor).isActive = true
        count.leftAnchor.constraint(equalTo: scroll.left, constant: 20).isActive = true
        
        bars.topAnchor.constraint(equalTo: scroll.top, constant: 30).isActive = true
        bars.leftAnchor.constraint(equalTo: scroll.left, constant: 10).isActive = true

        refresh()
    }
    
    override func refresh() {
        isUserInteractionEnabled = false
        scroll.views.filter { $0 is Card || $0 is Column }.forEach { $0.removeFromSuperview() }
        
        var left = tags.rightAnchor
        (0 ..< app.session.lists(app.project)).forEach {
            let column = Column(self, index: $0)
            scroll.add(column)
            
            if $0 == 0 {
                _add.leftAnchor.constraint(equalTo: column.leftAnchor, constant: 5).isActive = true
                _add.topAnchor.constraint(equalTo: column.bottomAnchor).isActive = true
            }
            
            var top: Card?
            (0 ..< app.session.cards(app.project, list: $0)).forEach {
                top = card($0, column: column, top: top)
            }
            
            column.leftAnchor.constraint(equalTo: left, constant: 10).isActive = true
            column.topAnchor.constraint(equalTo: scroll.top, constant: 10).isActive = true
            left = column.rightAnchor
        }
        
        scroll.right.constraint(greaterThanOrEqualTo: left, constant: 30).isActive = true
        tags.refresh()
        charts()
        isUserInteractionEnabled = true
    }
    
    override func found(_ ranges: [(Int, Int, NSRange)]) {
        scroll.views.compactMap { $0 as? Card }.forEach {
            $0.textStorage.removeAttribute(.backgroundColor, range: .init(location: 0, length: $0.text.count))
        }
    }
    
    override func select(_ list: Int, _ card: Int, _ range: NSRange) {
        scroll.views.compactMap { $0 as? Card }.forEach {
            $0.textStorage.removeAttribute(.backgroundColor, range: .init(location: 0, length: $0.text.utf16.count))
            if $0.column.index == list && $0.index == card {
                $0.textStorage.addAttribute(.backgroundColor, value: UIColor.haze(0.6), range: range)
                scroll.center(scroll.content.convert($0.layoutManager.boundingRect(forGlyphRange: range, in: $0.textContainer), from: $0))
            }
        }
    }
    
    override func add() {
        app.window!.endEditing(true)
        app.session.add(app.project, list: 0)
        let cards = scroll.views.compactMap { $0 as? Card }.filter { $0.column.index == 0 }
        let card = self.card(0, column: scroll.views.compactMap { $0 as? Column }.first { $0.index == 0 }!, top: nil)
        card.child = cards.first { $0.index == 0 }
        
        cards.forEach {
            $0.index += 1
        }
        
        card.top = card.topAnchor.constraint(equalTo: _add.topAnchor)
        scroll.content.layoutIfNeeded()
        card.top = card.topAnchor.constraint(equalTo: _add.bottomAnchor, constant: 20)
        
        UIView.animate(withDuration: 0.4, animations: { [weak self] in
            self?.scroll.content.layoutIfNeeded()
            self?.scroll.contentOffset.x = 0
            self?.scroll.contentOffset.y = 0
        }) { [weak self, weak card] _ in
            card?.edit()
            self?.charts()
        }
    }
    
    func charts() {
        count.attributed([("\((0 ..< app.session.lists(app.project)).map { app.session.cards(app.project, list: $0) }.reduce(0, +))", .bold(20), .haze()), (" " + .key("Kanban.count"), .regular(14), .haze())])
        bars.refresh()
    }
    
    private func card(_ index: Int, column: Column, top: Card?) -> Card {
        let card = Card(self, index: index)
        scroll.add(card)
        
        if top == nil {
            if column.index == 0 {
                card.top = card.topAnchor.constraint(equalTo: _add.bottomAnchor, constant: 20)
            } else {
                card.top = card.topAnchor.constraint(equalTo: column.bottomAnchor)
            }
        } else {
            top!.child = card
        }
        
        scroll.bottomAnchor.constraint(greaterThanOrEqualTo: card.bottomAnchor, constant: 30).isActive = true
        card.column = column
        card.update(false)
        return card
    }
    
    @objc private func column() {
        app.window!.endEditing(true)
        app.session.add(app.project)
        app.session.name(app.project, list: app.session.lists(app.project) - 1, name: .key("Kanban.new"))
        refresh()
        app.alert(app.session.name(app.project), message: .key("Kanban.added"))
    }
    
    @objc private func csv(_ control: Control) {
        app.window!.endEditing(true)
        app.session.csv(app.project) {
            guard app.project != nil else { return }
            let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(app.session.name(app.project) + ".csv")
            do {
                try $0.write(to: url, options: .atomic)
                let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                activity.popoverPresentationController?.sourceView = control
                app.present(activity, animated: true)
            } catch {
                app.alert(.key("Error"), message: error.localizedDescription)
            }
        }
    }
}
