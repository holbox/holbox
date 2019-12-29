import UIKit

final class Todo: View, UITextViewDelegate {
    private(set) weak var border: Border!
    private weak var scroll: Scroll!
    private weak var text: Text!
    private weak var ring: Ring!
    private weak var timeline: Timeline!
    private weak var count: Label!
    private weak var _add: Button!
    private weak var _bottom: NSLayoutConstraint!
    
    weak var _last: Task? {
        didSet {
            _bottom?.isActive = false
            if _last != nil {
                _bottom = scroll.bottom.constraint(greaterThanOrEqualTo: _last!.bottomAnchor, constant: 30)
                _bottom.isActive = true
            }
        }
    }
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let timeline = Timeline()
        scroll.add(timeline)
        self.timeline = timeline
        
        let ring = Ring()
        scroll.add(ring)
        self.ring = ring
        
        let _add = Button("plus", target: self, action: #selector(add))
        _add.accessibilityLabel = .key("Todo.add")
        scroll.add(_add)
        self._add = _add
        
        let count = Label([])
        count.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        scroll.add(count)
        self.count = count
        
        let text = Text(Storage())
        text.backgroundColor = .haze(0.2)
        text.layer.cornerRadius = 6
        text.isScrollEnabled = false
        text.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        text.accessibilityLabel = .key("Project")
        text.font = .regular(14)
        (text.textStorage as! Storage).attributes = [.plain: [.font: UIFont.regular(14), .foregroundColor: UIColor.white],
                                                     .emoji: [.font: UIFont.regular(18)],
                                                     .bold: [.font: UIFont.medium(16), .foregroundColor: UIColor.white],
                                                     .tag: [.font: UIFont.medium(12), .foregroundColor: UIColor.haze()]]
        text.delegate = self
        (text.layoutManager as! Layout).padding = 2
        scroll.add(text)
        self.text = text
        
        let border = Border.horizontal()
        scroll.add(border)
        self.border = border
        
        scroll.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        scroll.width.constraint(equalTo: safeAreaLayoutGuide.widthAnchor).isActive = true
        scroll.height.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.heightAnchor).isActive = true
        
        timeline.topAnchor.constraint(equalTo: scroll.top, constant: 10).isActive = true
        timeline.leftAnchor.constraint(equalTo: scroll.left, constant: 20).isActive = true
        timeline.rightAnchor.constraint(equalTo: scroll.right, constant: -20).isActive = true
        
        ring.topAnchor.constraint(equalTo: timeline.bottomAnchor, constant: 20).isActive = true
        ring.leftAnchor.constraint(equalTo: scroll.left, constant: 15).isActive = true
        
        count.centerYAnchor.constraint(equalTo: ring.centerYAnchor).isActive = true
        count.leftAnchor.constraint(equalTo: ring.rightAnchor, constant: 10).isActive = true
        
        _add.centerYAnchor.constraint(equalTo: ring.centerYAnchor).isActive = true
        _add.leftAnchor.constraint(equalTo: text.rightAnchor, constant: 5).isActive = true
        _add.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        text.topAnchor.constraint(equalTo: ring.topAnchor, constant: 15).isActive = true
        text.leftAnchor.constraint(equalTo: count.rightAnchor, constant: 20).isActive = true
        text.widthAnchor.constraint(equalToConstant: 160).isActive = true
        
        border.topAnchor.constraint(equalTo: text.bottomAnchor, constant: 50).isActive = true
        border.leftAnchor.constraint(equalTo: scroll.left).isActive = true
        border.rightAnchor.constraint(equalTo: scroll.right).isActive = true
        
        DispatchQueue.main.async { [weak self] in
            self?.refresh()
        }
    }
    
    override func rotate() {
        timeline.refresh()
    }
    
    override func refresh() {
        isUserInteractionEnabled = false
        scroll.views.filter { $0 is Task }.forEach { $0.removeFromSuperview() }
        
        var _last: Task?
        [0, 1].forEach { list in
            (0 ..< app.session.cards(app.project, list: list)).forEach {
                _last = task($0, list: list, parent: _last == nil ? border : _last!)
            }
        }
        
        self._last = _last
        charts()
        isUserInteractionEnabled = true
    }
    
    override func found(_ ranges: [(Int, Int, NSRange)]) {
        scroll.views.compactMap { $0 as? Task }.forEach {
            $0.text.textStorage.removeAttribute(.backgroundColor, range: .init(location: 0, length: $0.text.text.count))
        }
    }
    
    override func select(_ list: Int, _ card: Int, _ range: NSRange) {
        scroll.views.compactMap { $0 as? Task }.forEach {
            $0.text.textStorage.removeAttribute(.backgroundColor, range: .init(location: 0, length: $0.text.text.utf16.count))
            if $0.list == list && $0.index == card {
                $0.text.textStorage.addAttribute(.backgroundColor, value: UIColor.haze(0.6), range: range)
                scroll.center(scroll.content.convert($0.text.layoutManager.boundingRect(forGlyphRange: range, in: $0.text.textContainer), from: $0))
            }
        }
    }
    
    override func add() {
        if text.text.isEmpty {
            text.becomeFirstResponder()
        } else {
            if !text.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                app.session.add(app.project, list: 0, content: text.text)
                app.alert(.key("Task"), message: text.text)
                let tasks = scroll.views.compactMap { $0 as? Task }
                let new = task(0, list: 0, parent: border)
                new.backgroundColor = .haze(0.6)
                scroll.content.layoutIfNeeded()
                
                if let previous = tasks.first(where: { $0.index == 0 && $0.list == 0 }) {
                    previous._parent = new
                } else if let next = tasks.first(where: { $0.index == 0 && $0.list == 1 }) {
                    next._parent = new
                } else {
                    _last = new
                }
                tasks.filter { $0.list == 0 }.forEach { $0.index += 1 }
                
                UIView.animate(withDuration: 0.3, animations: { [weak self] in
                    self?.scroll.content.layoutIfNeeded()
                }) { _ in
                    UIView.animate(withDuration: 0.25) {
                        new.backgroundColor = .clear
                    }
                }
            }
            text.text = ""
            app.window!.endEditing(true)
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.scroll.contentOffset.y = 0
        }
    }
    
    func charts() {
        let amount = app.session.cards(app.project, list: 0) + app.session.cards(app.project, list: 1)
        count.attributed([("\(amount)", .medium(18), .haze()), ("\n" + (amount == 1 ? .key("Todo.count") : .key("Todo.counts")), .regular(12), .haze())])
        ring.refresh()
        timeline.refresh()
    }
    
    private func task(_ index: Int, list: Int, parent: UIView) -> Task {
        let task = Task(index, list: list, todo: self)
        scroll.add(task)
        
        task._parent = parent
        task.leftAnchor.constraint(equalTo: scroll.left).isActive = true
        task.rightAnchor.constraint(equalTo: scroll.right).isActive = true
        return task
    }
}
