import AppKit

final class Todo: Base.View, NSTextViewDelegate {
    private weak var scroll: Scroll!
    private weak var new: Text!
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let new = Text(.Vertical(500))
        new.setAccessibilityLabel(.key("Task"))
        (new.textStorage as! Storage).fonts = [.plain: .systemFont(ofSize: 16, weight: .medium),
                                               .emoji: .systemFont(ofSize: 32, weight: .regular),
                                               .bold: .systemFont(ofSize: 24, weight: .bold)]
        new.tab = true
        new.intro = true
        new.string = "hello world"
        addSubview(new)
        self.new = new
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        scroll.right.constraint(equalTo: rightAnchor).isActive = true

        new.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        new.leftAnchor.constraint(greaterThanOrEqualTo: scroll.left).isActive = true
        new.rightAnchor.constraint(lessThanOrEqualTo: scroll.right).isActive = true
        new.topAnchor.constraint(equalTo: scroll.top, constant: 40).isActive = true
        
//        new.didChangeText()
        new.delegate = self
    }
    
    override func layout() {
        super.layout()
        new.needsLayout = true
    }
    
    override func refresh() {
        scroll.views.filter { $0 is Task }.forEach { $0.removeFromSuperview() }
    }
}