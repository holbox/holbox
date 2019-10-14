import AppKit

final class Detail: NSView {
    private final class Item: NSView {
        override var mouseDownCanMoveWindow: Bool { false }
        private weak var label: Label!
        private let index: Int
        
        required init?(coder: NSCoder) { nil }
        init(_ index: Int) {
            self.index = index
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            setAccessibilityElement(true)
            setAccessibilityRole(.button)
            setAccessibilityLabel(session.name(index))
            wantsLayer = true
            layer!.cornerRadius = 20
            
            let label = Label(session.name(index))
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            label.setAccessibilityElement(true)
            label.textColor = .white
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            addSubview(label)
            self.label = label
            
            heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        }
        
        override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }
        
        override func mouseDown(with: NSEvent) {
            layer!.backgroundColor = .haze
            label.textColor = .black
        }
        
        override func mouseUp(with: NSEvent) {
            if bounds.contains(convert(with.locationInWindow, from: nil)) {
                main.project(index)
            } else {
                layer!.backgroundColor = .clear
                label.textColor = .white
            }
        }
    }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        
        let scroll = Scroll()
        addSubview(scroll)
        
        let _add = Button("plus", target: self, action: #selector(add))
        addSubview(_add)
        
        let image = Image("detail.\(main.mode.rawValue)")
        scroll.documentView!.addSubview(image)
        
        let title = Label(.key("Detail.title.\(main.mode.rawValue)"))
        title.font = .systemFont(ofSize: 30, weight: .bold)
        title.textColor = .init(white: 1, alpha: 0.3)
        scroll.documentView!.addSubview(title)
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = .black
        scroll.documentView!.addSubview(border)
        
        if session.projects(main.mode).isEmpty {
            let empty = Label(.key("Detail.empty.\(main.mode.rawValue)"))
            empty.font = .systemFont(ofSize: 14, weight: .light)
            empty.textColor = .init(white: 1, alpha: 0.4)
            scroll.documentView!.addSubview(empty)
            
            empty.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 20).isActive = true
            empty.leftAnchor.constraint(equalTo: scroll.leftAnchor, constant: 60).isActive = true
            
            scroll.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: empty.bottomAnchor, constant: 40).isActive = true
        } else {
            var top: NSLayoutYAxisAnchor?
            session.projects(main.mode).forEach {
                let item = Item($0)
                scroll.documentView!.addSubview(item)
                
                item.leftAnchor.constraint(equalTo: scroll.leftAnchor, constant: 40).isActive = true
                item.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -80).isActive = true
                
                if top == nil {
                    item.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
                } else {
                    let border = NSView()
                    border.translatesAutoresizingMaskIntoConstraints = false
                    border.wantsLayer = true
                    border.layer!.backgroundColor = .black
                    scroll.documentView!.addSubview(border)
                    
                    border.leftAnchor.constraint(equalTo: scroll.leftAnchor, constant: 60).isActive = true
                    border.rightAnchor.constraint(equalTo: scroll.rightAnchor, constant: -60).isActive = true
                    border.heightAnchor.constraint(equalToConstant: 1).isActive = true
                    border.topAnchor.constraint(equalTo: top!).isActive = true
                    
                    item.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
                }
                
                top = item.bottomAnchor
            }
            scroll.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: top!, constant: 20).isActive = true
        }
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.documentView!.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        _add.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 60).isActive = true
        _add.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        _add.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        image.widthAnchor.constraint(equalToConstant: 300).isActive = true
        image.heightAnchor.constraint(equalToConstant: 200).isActive = true
        image.topAnchor.constraint(equalTo: scroll.documentView!.topAnchor, constant: 50).isActive = true
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        title.leftAnchor.constraint(equalTo: scroll.leftAnchor, constant: 60).isActive = true
        title.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 20).isActive = true
        
        border.leftAnchor.constraint(equalTo: scroll.documentView!.leftAnchor, constant: 60).isActive = true
        border.rightAnchor.constraint(equalTo: scroll.documentView!.rightAnchor, constant: -60).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20).isActive = true
    }
    
    @objc private func add() {
        app.runModal(for: Add())
    }
}
