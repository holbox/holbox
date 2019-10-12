import AppKit

final class Detail: NSView {
    private final class Item: NSView {
        override var mouseDownCanMoveWindow: Bool { false }
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
            layer!.cornerRadius = 12
            
            let label = Label(session.name(index))
            label.font = .systemFont(ofSize: 14, weight: .regular)
            label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            label.setAccessibilityElement(true)
            label.textColor = .white
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            addSubview(label)
            
            heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        }
        
        override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }
        override func mouseDown(with: NSEvent) { layer!.backgroundColor = NSColor.haze.withAlphaComponent(0.9).cgColor }
        override func mouseUp(with: NSEvent) {
            if bounds.contains(convert(with.locationInWindow, from: nil)) { main.project(index) }
            layer!.backgroundColor = .clear
        }
    }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        
        let image = Image("detail.\(main.mode.rawValue)")
        addSubview(image)
        
        let title = Label(.key("Detail.title.\(main.mode.rawValue)"))
        title.font = .systemFont(ofSize: 20, weight: .bold)
        title.textColor = .white
        addSubview(title)
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = .black
        addSubview(border)
        
        if session.projects(main.mode).isEmpty {
            let empty = Label(.key("Detail.empty.\(main.mode.rawValue)"))
            empty.font = .systemFont(ofSize: 14, weight: .light)
            empty.textColor = .init(white: 1, alpha: 0.4)
            addSubview(empty)
            
            empty.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 20).isActive = true
            empty.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
        } else {
            let scroll = Scroll()
            addSubview(scroll)
            
            var top: NSLayoutYAxisAnchor?
            session.projects(main.mode).forEach {
                let item = Item($0)
                scroll.documentView!.addSubview(item)
                
                item.leftAnchor.constraint(equalTo: scroll.leftAnchor, constant: 20).isActive = true
                item.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -40).isActive = true
                
                if top == nil {
                    item.topAnchor.constraint(equalTo: scroll.documentView!.topAnchor).isActive = true
                } else {
                    let border = NSView()
                    border.translatesAutoresizingMaskIntoConstraints = false
                    border.wantsLayer = true
                    border.layer!.backgroundColor = .black
                    scroll.documentView!.addSubview(border)
                    
                    border.leftAnchor.constraint(equalTo: scroll.leftAnchor, constant: 40).isActive = true
                    border.rightAnchor.constraint(equalTo: scroll.rightAnchor, constant: -40).isActive = true
                    border.heightAnchor.constraint(equalToConstant: 1).isActive = true
                    border.topAnchor.constraint(equalTo: top!).isActive = true
                    
                    item.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
                }
                
                top = item.bottomAnchor
            }
            
            scroll.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
            scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
            scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            scroll.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: top!).isActive = true
        }
        
        image.widthAnchor.constraint(equalToConstant: 300).isActive = true
        image.heightAnchor.constraint(equalToConstant: 200).isActive = true
        image.topAnchor.constraint(equalTo: topAnchor, constant: 50).isActive = true
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
        title.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 40).isActive = true
        
        border.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor, constant: -40).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10).isActive = true
    }
}
