import UIKit

final class Card: UIView {
    private final class Move: Modal {
        private weak var card: Card!
        private weak var scroll: Scroll!
        private weak var position: Label!
        private weak var stepper: UIStepper!
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
            
            let scroll = Scroll()
            view.addSubview(scroll)
            self.scroll = scroll
            
            let done = Capsule(.key("Card.move.done"), self, #selector(close), UIColor(named: "haze")!, .black)
            scroll.add(done)
            
            let _column = Label(.key("Card.move.column"), 24, .bold, .init(white: 1, alpha: 0.3))
            scroll.add(_column)
            
            var top: NSLayoutYAxisAnchor?
            (0 ..< app.session.lists(app.project)).forEach {
                let item = Item(app.session.name(app.project, list: $0) + ": \(app.session.cards(app.project, list: $0))", index: $0, .bold, self, #selector(column))
                item.selected = card.column == $0
                scroll.add(item)
                
                item.leftAnchor.constraint(equalTo: scroll.safeAreaLayoutGuide.leftAnchor, constant: 40).isActive = true
                item.widthAnchor.constraint(equalTo: scroll.safeAreaLayoutGuide.widthAnchor, constant: -80).isActive = true
                
                if top == nil {
                    item.topAnchor.constraint(equalTo: _column.bottomAnchor, constant: 10).isActive = true
                } else {
                    let border = Border()
                    border.alpha = 0.2
                    scroll.add(border)
                    
                    border.leftAnchor.constraint(equalTo: scroll.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
                    border.rightAnchor.constraint(equalTo: scroll.safeAreaLayoutGuide.rightAnchor, constant: -60).isActive = true
                    border.topAnchor.constraint(equalTo: top!).isActive = true
                    
                    item.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
                }
                
                top = item.bottomAnchor
            }
            
            let _position = Label(.key("Card.move.position"), 24, .bold, .init(white: 1, alpha: 0.3))
            scroll.add(_position)
            
            let position = Label("", 25, .bold, .white)
            scroll.addSubview(position)
            self.position = position
            
            let stepper = UIStepper()
            stepper.translatesAutoresizingMaskIntoConstraints = false
            stepper.addTarget(self, action: #selector(changed), for: .valueChanged)
            stepper.tintColor = UIColor(named: "haze")!
            scroll.addSubview(stepper)
            self.stepper = stepper
            
            scroll.bottom.constraint(greaterThanOrEqualTo: _position.bottomAnchor, constant: 60).isActive = true
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1).isActive = true
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -1).isActive = true
            scroll.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
            scroll.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
            
            done.topAnchor.constraint(equalTo: scroll.top, constant: 10).isActive = true
            done.rightAnchor.constraint(equalTo: scroll.right, constant: -20).isActive = true
            done.widthAnchor.constraint(equalToConstant: 70).isActive = true
            
            _column.topAnchor.constraint(equalTo: done.bottomAnchor, constant: 20).isActive = true
            _column.leftAnchor.constraint(equalTo: scroll.left, constant: 60).isActive = true
            
            _position.topAnchor.constraint(equalTo: top!, constant: 50).isActive = true
            _position.leftAnchor.constraint(equalTo: scroll.left, constant: 60).isActive = true
            
            position.centerYAnchor.constraint(equalTo: _position.centerYAnchor).isActive = true
            position.rightAnchor.constraint(equalTo: stepper.leftAnchor, constant: -20).isActive = true
            
            stepper.centerYAnchor.constraint(equalTo: _position.centerYAnchor).isActive = true
            stepper.rightAnchor.constraint(equalTo: scroll.right, constant: -60).isActive = true
            
            limits()
            update()
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            let index = self.index
            let list = self.list
            if index != card.index || list != card.column {
                app.dismiss(animated: true) { [weak card] in
                    card?.move(list, position: index)
                }
            }
        }
        
        private func update() {
            position.text = "\(index + 1)"
        }
        
        private func limits() {
            let max = app.session.cards(app.project, list: list) - (list == card.column ? 1 : 0)
            stepper.maximumValue = .init(max)
            if index >= max {
                index = max
            }
            stepper.value = .init(index)
        }
        
        @objc private func column(_ item: Item) {
            scroll.views.compactMap { $0 as? Item }.forEach { $0.selected = $0 === item }
            list = item.index
            limits()
            update()
        }
        
        @objc private func changed() {
            index = .init(stepper.value)
            update()
        }
    }
    
    private final class Detail: Edit {
        private weak var card: Card!
        
        required init?(coder: NSCoder) { nil }
        init(_ card: Card) {
            super.init(nibName: nil, bundle: nil)
            self.card = card
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            text.text = card.content.text!
            
            let _delete = Capsule(.key("Card.delete"), self, #selector(remove), .black, UIColor(named: "haze")!)
            view.addSubview(_delete)
            
            let _move = Capsule(.key("Card.move"), self, #selector(move), .black, UIColor(named: "haze")!)
            view.addSubview(_move)
            
            _delete.topAnchor.constraint(equalTo: done.topAnchor).isActive = true
            _delete.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            _delete.widthAnchor.constraint(equalToConstant: 80).isActive = true
            
            _move.topAnchor.constraint(equalTo: done.topAnchor).isActive = true
            _move.leftAnchor.constraint(equalTo: _delete.rightAnchor, constant: 20).isActive = true
            _move.widthAnchor.constraint(equalToConstant: 80).isActive = true
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            card.update(false)
        }
        
        override func textViewDidEndEditing(_: UITextView) {
            card.update(text.text)
        }
        
        @objc private func move() {
            app.win.endEditing(true)
            present(Move(card), animated: true)
        }
        
        @objc private func remove() {
            app.win.endEditing(true)
            let alert = UIAlertController(title: .key("Delete.title.card.\(app.mode.rawValue)"), message: nil, preferredStyle: .actionSheet)
            alert.addAction(.init(title: .key("Delete.confirm"), style: .destructive) { [weak self] _ in
                self?.presentingViewController!.dismiss(animated: true) { [weak self] in
                    self?.card.delete()
                }
            })
            alert.addAction(.init(title: .key("Delete.cancel"), style: .cancel))
            alert.popoverPresentationController?.sourceView = view
            alert.popoverPresentationController?.sourceRect = .init(x: view.bounds.midX, y: 0, width: 1, height: 1)
            present(alert, animated: true)
        }
    }
    
    let index: Int
    let column: Int
    private weak var content: UILabel!
    private weak var base: UIView!
    private weak var kanban: Kanban!

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
        base.layer.borderColor = UIColor.black.cgColor
        addSubview(base)
        self.base = base
        
        let content = Label(app.session.content(app.project, list: column, card: index), 14, .light, .white)
        content.font = .monospacedSystemFont(ofSize: 14, weight: .light)
        content.accessibilityLabel = .key("Card")
        content.accessibilityValue = app.session.content(app.project, list: column, card: index)
        addSubview(content)
        self.content = content
        
        rightAnchor.constraint(equalTo: content.rightAnchor, constant: 30).isActive = true
        bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: 30).isActive = true
        
        base.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        base.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        base.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        
        content.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        content.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
        content.widthAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        
        update(false)
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
        content.text = text
        app.session.content(app.project, list: column, card: index, content: text)
    }
    
    private func update(_ active: Bool) {
        base.layer.borderWidth = content.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 1 : 0
        base.backgroundColor = active ? UIColor(named: "haze")! : .clear
        content.textColor = active ? .black : .white
        content.alpha = active ? 1 : 0.8
    }
    
    private func move(_ destination: Int, position: Int) {
        app.session.move(app.project, list: column, card: index, destination: destination, index: position)
        kanban.refresh()
    }
    
    @objc private func delete() {
        app.session.delete(app.project, list: column, card: index)
        kanban.refresh()
    }
}
