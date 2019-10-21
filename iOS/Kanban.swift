import UIKit

final class Kanban: UIView {
    private weak var scroll: Scroll!
    private weak var name: Label!
    private weak var border: Border!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let border = Border()
        scroll.add(border)
        self.border = border
        
        let name = Label(app.session.name(app.project), 30, .bold, .white)
        name.accessibilityLabel = .key("Kanban.project")
        name.accessibilityValue = app.session.name(app.project)
        name.alpha = 0.2
        addSubview(name)
        self.name = name
        
        let _card = Button("card", target: self, action: #selector(card))
        let _more = Button("more", target: self, action: #selector(more))
        
        [_card, _more].forEach {
            scroll.add($0)
            $0.widthAnchor.constraint(equalToConstant: 60).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 60).isActive = true
            $0.centerYAnchor.constraint(equalTo: name.centerYAnchor).isActive = true
        }

        scroll.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        scroll.right.constraint(greaterThanOrEqualTo: _more.rightAnchor, constant: 60).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: name.bottomAnchor, constant: 60).isActive = true
        
        _card.leftAnchor.constraint(equalTo: name.rightAnchor, constant: 20).isActive = true
        _more.leftAnchor.constraint(equalTo: _card.rightAnchor).isActive = true
        
        border.leftAnchor.constraint(equalTo: scroll.left).isActive = true
        border.rightAnchor.constraint(equalTo: scroll.right).isActive = true
        border.topAnchor.constraint(equalTo: scroll.top, constant: 165).isActive = true
        
        name.topAnchor.constraint(equalTo: scroll.top, constant: 40).isActive = true
        name.leftAnchor.constraint(equalTo: scroll.left, constant: 40).isActive = true
        refresh()
    }
    
    private func refresh() {
        scroll.views.filter { $0 is Card || $0 is Column }.forEach { $0.removeFromSuperview() }
        var left: NSLayoutXAxisAnchor?
        (0 ..< app.session.lists(app.project)).forEach { list in
            let column = Column(list)
            scroll.add(column)
            
            var top: Card?
            (0 ..< app.session.cards(app.project, list: list)).forEach {
                let card = Card($0, column: list)
                scroll.add(card)
                
                if top == nil {
                    card.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 10).isActive = true
                } else {
                    card.topAnchor.constraint(equalTo: top!.bottomAnchor, constant: 10).isActive = true
                }
                
                scroll.bottom.constraint(greaterThanOrEqualTo: card.bottomAnchor, constant: 60).isActive = true
                column.rightAnchor.constraint(greaterThanOrEqualTo: card.rightAnchor, constant: 10).isActive = true
                card.leftAnchor.constraint(equalTo: column.leftAnchor, constant: 10).isActive = true
                top = card
            }
            
            if left == nil {
                column.leftAnchor.constraint(equalTo: scroll.left).isActive = true
            } else {
                column.leftAnchor.constraint(equalTo: left!).isActive = true
            }
            
            column.topAnchor.constraint(equalTo: scroll.top, constant: 90).isActive = true
            scroll.bottom.constraint(greaterThanOrEqualTo: column.bottomAnchor, constant: 40).isActive = true
            left = column.rightAnchor
        }
        
        if left != nil {
            let space = UIView()
            space.isUserInteractionEnabled = false
            space.translatesAutoresizingMaskIntoConstraints = false
            scroll.content.insertSubview(space, at: 0)
            
            space.widthAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
            space.leftAnchor.constraint(equalTo: left!).isActive = true
            scroll.right.constraint(greaterThanOrEqualTo: space.rightAnchor).isActive = true
        }
    }
    
    @objc private func card() {
        app.session.add(app.project, list: 0)
        refresh()
        scroll.views.compactMap { $0 as? Card }.first { $0.index == 0 && $0.column == 0 }!.edit()
    }
    
    @objc private func more() {
//        app.runModal(for: More.Project())
    }
}
