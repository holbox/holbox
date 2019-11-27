import UIKit

final class Card: UIView {
    private final class Move: UIViewController {
        private weak var card: Card?
        private weak var scroll: Scroll!
        private weak var position: Label!
        private weak var total: Label!
        private weak var _plus: Button!
        private weak var _minus: Button!
        private var index = 0
        private var list = 0
        
        required init?(coder: NSCoder) { nil }
        init(_ card: Card) {
            super.init(nibName: nil, bundle: nil)
            index = card.index
            list = card.column
            self.card = card
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            guard let card = self.card else { return }
            
            let scroll = Scroll()
            view.addSubview(scroll)
            self.scroll = scroll
            
            let done = Capsule(.key("Card.move.done"), self, #selector(close), UIColor(named: "haze")!, .black)
            scroll.add(done)
            
            let _column = Label(.key("Card.move.title"), 22, .bold, .init(white: 1, alpha: 0.2))
            scroll.add(_column)
            
            var top: NSLayoutYAxisAnchor?
//            (0 ..< app.session.lists(app.project)).forEach {
//                let item = Item(app.session.name(app.project, list: $0), index: $0, .bold, 18, .init(white: 1, alpha: 0.5), self, #selector(column))
//                item.selected = card.column == $0
//                scroll.add(item)
//                
//                item.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
//                item.widthAnchor.constraint(equalToConstant: 200).isActive = true
//                
//                if top == nil {
//                    item.topAnchor.constraint(equalTo: _column.bottomAnchor, constant: 15).isActive = true
//                } else {
//                    let border = Border()
//                    border.backgroundColor = .init(white: 0, alpha: 0.5)
//                    scroll.add(border)
//                    
//                    border.leftAnchor.constraint(equalTo: item.leftAnchor, constant: 20).isActive = true
//                    border.rightAnchor.constraint(equalTo: item.rightAnchor, constant: -20).isActive = true
//                    border.topAnchor.constraint(equalTo: top!).isActive = true
//                    
//                    item.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
//                }
//                
//                top = item.bottomAnchor
//            }
            
            let _position = Label(.key("Card.move.position"), 22, .bold, .init(white: 1, alpha: 0.2))
            scroll.add(_position)
            
            let position = Label("", 30, .bold, .white)
            scroll.addSubview(position)
            self.position = position
            
            let total = Label("", 16, .medium, .white)
            scroll.addSubview(total)
            self.total = total
            
            let _plus = Button("plus", target: self, action: #selector(plus))
            scroll.addSubview(_plus)
            self._plus = _plus
            
            let _minus = Button("minus", target: self, action: #selector(minus))
            scroll.addSubview(_minus)
            self._minus = _minus
            
            scroll.bottom.constraint(greaterThanOrEqualTo: done.bottomAnchor, constant: 20).isActive = true
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1).isActive = true
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -1).isActive = true
            scroll.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
            scroll.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
            
            done.centerXAnchor.constraint(equalTo: scroll.centerXAnchor).isActive = true
            done.topAnchor.constraint(equalTo: _plus.bottomAnchor, constant: 40).isActive = true
            
            _column.topAnchor.constraint(equalTo: scroll.top, constant: 50).isActive = true
            _column.leftAnchor.constraint(equalTo: scroll.left, constant: 43).isActive = true
            
            _position.topAnchor.constraint(equalTo: top!, constant: 56).isActive = true
            _position.leftAnchor.constraint(equalTo: scroll.left, constant: 43).isActive = true
            
            position.centerYAnchor.constraint(equalTo: _position.centerYAnchor).isActive = true
            position.rightAnchor.constraint(equalTo: scroll.centerX).isActive = true
            
            total.bottomAnchor.constraint(equalTo: position.bottomAnchor, constant: -3).isActive = true
            total.leftAnchor.constraint(equalTo: position.rightAnchor, constant: 1).isActive = true
            
            _plus.topAnchor.constraint(equalTo: position.bottomAnchor, constant: 20).isActive = true
            _plus.leftAnchor.constraint(equalTo: scroll.centerX).isActive = true
            _plus.widthAnchor.constraint(equalToConstant: 70).isActive = true
            _plus.heightAnchor.constraint(equalToConstant: 70).isActive = true
            
            _minus.topAnchor.constraint(equalTo: _plus.topAnchor).isActive = true
            _minus.rightAnchor.constraint(equalTo: scroll.centerX).isActive = true
            _minus.widthAnchor.constraint(equalToConstant: 70).isActive = true
            _minus.heightAnchor.constraint(equalToConstant: 70).isActive = true

            update()
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            guard let card = self.card else { return }
            let index = self.index
            let list = self.list
            if index != card.index || list != card.column {
                app.dismiss(animated: true) { [weak card] in
                    card?.move(list, position: index)
                }
            }
        }
        
        private func update() {
//            guard let card = self.card else { return }
//            let limit = app.session.cards(app.project, list: list) + (list == card.column ? 0 : 1)
//            if index >= limit {
//                index = limit - 1
//            }
//            _minus.isUserInteractionEnabled = index > 0
//            _plus.isUserInteractionEnabled = index < limit - 1
//            _minus.alpha = index < 1 ? 0.3 : 1
//            _plus.alpha = index < limit - 1 ? 1 : 0.3
//            position.text = "\(index + 1)"
//            total.text = "/\(limit)"
        }
        
//        @objc private func column(_ item: Item) {
//            scroll.views.compactMap { $0 as? Item }.forEach {
//                $0.selected = $0 === item
//                $0.highlighted = false
//            }
//            list = item.index
//            update()
//        }
        
        @objc private func plus() {
            index += 1
            update()
        }
        
        @objc private func close() {
            
        }
        
        @objc private func minus() {
            index -= 1
            update()
        }
    }
    
    private final class Detail: Edit {
        private weak var card: Card?
        private weak var _delete: Capsule!
        
        required init?(coder: NSCoder) { nil }
        init(_ card: Card) {
            super.init()
            self.card = card
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            guard let card = self.card else { return }
//            text.text = app.session.content(app.project, list: card.column, card: card.index)
//
//            let _delete = Capsule(.key("Card.delete"), self, #selector(remove), UIColor(named: "background")!, UIColor(named: "haze")!)
//            view.addSubview(_delete)
//            self._delete = _delete
//
//            let _move = Capsule(.key("Card.move"), self, #selector(move), UIColor(named: "background")!, UIColor(named: "haze")!)
//            view.addSubview(_move)
//
//            _delete.topAnchor.constraint(equalTo: done.topAnchor).isActive = true
//            _delete.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 15).isActive = true
//
//            _move.topAnchor.constraint(equalTo: done.topAnchor).isActive = true
//            _move.leftAnchor.constraint(equalTo: _delete.rightAnchor).isActive = true
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            card?.update(false)
        }
        
        override func textViewDidEndEditing(_: UITextView) {
            card?.update(text.text)
        }
        
        @objc private func move() {
//            app.win.endEditing(true)
//            guard let card = self.card else { return }
//            present(Move(card), animated: true)
        }
        
        @objc private func remove() {
//            app.win.endEditing(true)
//            if text.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                presentingViewController!.dismiss(animated: true) { [weak self] in
//                    self?.card?.delete()
//                }
//            } else {
//                let alert = UIAlertController(title: .key("Delete.title.card.\(app.mode.rawValue)"), message: nil, preferredStyle: .actionSheet)
//                alert.addAction(.init(title: .key("Delete.confirm"), style: .destructive) { [weak self] _ in
//                    self?.presentingViewController!.dismiss(animated: true) { [weak self] in
//                        self?.card?.delete()
//                    }
//                })
//                alert.addAction(.init(title: .key("Delete.cancel"), style: .cancel))
//                alert.popoverPresentationController?.sourceView = _delete
//                present(alert, animated: true)
//            }
        }
    }
    
    let index: Int
    let column: Int
    private weak var empty: Image?
    private weak var content: Label?
    private weak var kanban: Kanban?
    private weak var base: UIView!
    
    required init?(coder: NSCoder) { nil }
    init(_ kanban: Kanban, index: Int, column: Int) {
        self.index = index
        self.column = column
        self.kanban = kanban
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let base = UIView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.isUserInteractionEnabled = false
        base.layer.cornerRadius = 8
        addSubview(base)
        self.base = base
        
        base.topAnchor.constraint(equalTo: topAnchor, constant: 1).isActive = true
        base.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        base.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true

        update()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        update(true)
        super.touchesBegan(touches, with: with)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with: UIEvent?) {
        update(false)
        super.touchesCancelled(touches, with: with)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        if app.presentedViewController == nil && bounds.contains(touches.first!.location(in: self)) {
            app.present(Detail(self), animated: true)
        } else {
            update(false)
        }
        super.touchesEnded(touches, with: with)
    }
    
    func edit() {
        UIView.animate(withDuration: 0.35, animations: { [weak self] in
            self?.update(true)
        }) { [weak self] _ in
            guard let self = self else { return }
            app.present(Detail(self), animated: true)
        }
    }
    
    private func update(_ text: String) {
        if text != app.session.content(app.project!, list: column, card: index) {
            app.session.content(app.project!, list: column, card: index, content: text)
            app.alert(.key("Card"), message: text)
            update()
            update(true)
        }
    }
    
    private func update(_ active: Bool) {
        base.backgroundColor = active ? UIColor(named: "haze")! : .clear
        content?.textColor = active ? .black : .white
    }
    
    private func update() {
        content?.removeFromSuperview()
        empty?.removeFromSuperview()
        let string = app.session.content(app.project!, list: column, card: index)
        if string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let empty = Image("empty")
            addSubview(empty)
            self.empty = empty

            rightAnchor.constraint(equalTo: empty.rightAnchor, constant: 16).isActive = true
            bottomAnchor.constraint(equalTo: empty.bottomAnchor, constant: 16).isActive = true

            empty.widthAnchor.constraint(equalToConstant: 34).isActive = true
            empty.heightAnchor.constraint(equalToConstant: 34).isActive = true
            empty.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
            empty.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        } else {
            let content = Label(string.mark {
                switch $0 {
                case .plain: return (.init(string[$1]), 16, .medium, .white)
                case .emoji: return (.init(string[$1]), 32, .regular, .white)
                case .bold: return (.init(string[$1]), 20, .bold, .white)
                case .tag: return (.init(string[$1]), 16, .medium, .white)
                }
            })
            content.accessibilityLabel = .key("Card")
            content.accessibilityValue = string
            content.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            addSubview(content)
            self.content = content

            rightAnchor.constraint(equalTo: content.rightAnchor, constant: 20).isActive = true
            bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: 20).isActive = true

            content.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            content.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
            content.widthAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
            content.widthAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
            content.heightAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
        }
    }
    
    private func move(_ destination: Int, position: Int) {
//        app.session.move(app.project, list: column, card: index, destination: destination, index: position)
//        kanban.refresh()
    }
    
    @objc private func delete() {
//        app.alert(.key("Delete.deleted.card.\(app.mode.rawValue)"), message: app.session.content(app.project, list: column, card: index))
//        app.session.delete(app.project, list: column, card: index)
//        kanban.refresh()
    }
}
