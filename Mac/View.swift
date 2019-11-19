import AppKit

class View: NSView {
    weak var top: NSLayoutConstraint! { didSet { top.isActive = true }  }
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
    }
    
    func refresh() { }
    
    override func mouseDown(with: NSEvent) {
        super.mouseDown(with: with)
        window!.makeFirstResponder(self)
    }
    
    @objc func add() {
        
    }
    
    @objc func search() {
        
    }
}
