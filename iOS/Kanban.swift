import UIKit

final class Kanban: Base.View {
    private final class Detail: Edit {
        private weak var kanban: Kanban!
        
        required init?(coder: NSCoder) { nil }
        init(_ kanban: Kanban) {
            super.init(nibName: nil, bundle: nil)
            self.kanban = kanban
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            text.text = app.session.name(app.project)
            
            let _delete = Capsule(.key("Kanban.delete"), self, #selector(remove), .black, UIColor(named: "haze")!)
            view.addSubview(_delete)
            
            _delete.topAnchor.constraint(equalTo: done.topAnchor).isActive = true
            _delete.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            _delete.widthAnchor.constraint(equalToConstant: 80).isActive = true
        }
        
        override func textViewDidEndEditing(_: UITextView) {
            kanban.name.text = text.text
            app.session.name(app.project, name: text.text)
        }
        
        @objc private func remove() {
            app.win.endEditing(true)
            let alert = UIAlertController(title: .key("Delete.title.\(app.mode.rawValue)"), message: app.session.name(app.project), preferredStyle: .actionSheet)
            alert.addAction(.init(title: .key("Delete.confirm"), style: .destructive) { [weak self] _ in
                self?.presentingViewController!.dismiss(animated: true) {
                    app.session.delete(app.project)
                    app.main.kanban()
                }
            })
            alert.addAction(.init(title: .key("Delete.cancel"), style: .cancel))
            alert.popoverPresentationController?.sourceView = view
            alert.popoverPresentationController?.sourceRect = .init(x: view.bounds.midX, y: 0, width: 1, height: 1)
            present(alert, animated: true)
        }
    }
    
    private weak var scroll: Scroll!
    private weak var name: Label!
    private weak var border: Border!
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let border = Border()
        scroll.add(border)
        self.border = border
        
        let name = Label(app.session.name(app.project), 30, .bold, .white)
        name.accessibilityLabel = .key("Kanban.project")
        name.accessibilityValue = app.session.name(app.project)
        name.numberOfLines = 1
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

        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scroll.content.safeAreaLayoutGuide.rightAnchor.constraint(greaterThanOrEqualTo: _more.rightAnchor, constant: 20).isActive = true
        scroll.content.safeAreaLayoutGuide.bottomAnchor.constraint(greaterThanOrEqualTo: name.bottomAnchor, constant: 60).isActive = true
        
        _card.leftAnchor.constraint(equalTo: name.rightAnchor, constant: 20).isActive = true
        _more.leftAnchor.constraint(equalTo: _card.rightAnchor).isActive = true
        
        border.leftAnchor.constraint(equalTo: scroll.left).isActive = true
        border.rightAnchor.constraint(equalTo: scroll.right).isActive = true
        border.topAnchor.constraint(equalTo: scroll.top, constant: 165).isActive = true
        
        name.topAnchor.constraint(equalTo: scroll.top, constant: 40).isActive = true
        name.leftAnchor.constraint(equalTo: scroll.left, constant: 40).isActive = true
        name.widthAnchor.constraint(lessThanOrEqualToConstant: 400).isActive = true
        
        refresh()
    }
    
    override func refresh() {
        scroll.views.filter { $0 is Card || $0 is Column }.forEach { $0.removeFromSuperview() }
        var left: NSLayoutXAxisAnchor?
        (0 ..< app.session.lists(app.project)).forEach { list in
            let column = Column(list)
            scroll.add(column)
            
            var top: Card?
            (0 ..< app.session.cards(app.project, list: list)).forEach {
                let card = Card(self, index: $0, column: list)
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
        app.present(Detail(self), animated: true)
    }
}
