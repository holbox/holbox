import UIKit

class Text: UITextView {
    var caret = CGFloat(2)
    weak var width: NSLayoutConstraint! { didSet { oldValue?.isActive = false; width.isActive = true } }
    weak var height: NSLayoutConstraint! { didSet { oldValue?.isActive = false; height.isActive = true } }
    override var accessibilityValue: String? { get { text } set { } }
    
    required init?(coder: NSCoder) { nil }
    init(_ storage: NSTextStorage) {
        super.init(frame: .zero, textContainer: Container(storage))
        translatesAutoresizingMaskIntoConstraints = false
        textContainerInset = .zero
        isAccessibilityElement = true
        indicatorStyle = .white
        backgroundColor = .clear
        bounces = false
        tintColor = .haze()
        keyboardAppearance = .dark
        keyboardDismissMode = .interactive
        spellCheckingType = app.session.spell ? .yes : .no
        autocorrectionType = app.session.spell ? .yes : .no
        autocapitalizationType = app.session.spell ? .sentences : .none
        
        let accessory = UIView(frame: .init(x: 0, y: 0, width: 0, height: 50))
        accessory.backgroundColor = .black
        
        let border = Border.horizontal(1)
        accessory.addSubview(border)
        
        let _done = Button("commit", target: self, action: #selector(resignFirstResponder))
        _done.accessibilityLabel = .key("Done")
        accessory.addSubview(_done)
        
        let _clear = Control(.key("Clear"), self, #selector(clear), .haze(), .black)
        accessory.addSubview(_clear)
                
        let _bold = Button("hash", target: self, action: #selector(bold))
        accessory.addSubview(_bold)
        
        border.topAnchor.constraint(equalTo: accessory.topAnchor).isActive = true
        border.leftAnchor.constraint(equalTo: accessory.leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: accessory.rightAnchor).isActive = true
        
        _done.centerYAnchor.constraint(equalTo: accessory.centerYAnchor).isActive = true
        _done.rightAnchor.constraint(equalTo: accessory.safeAreaLayoutGuide.rightAnchor).isActive = true
        _done.widthAnchor.constraint(equalToConstant: 80).isActive = true
        _done.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        _clear.centerYAnchor.constraint(equalTo: accessory.centerYAnchor).isActive = true
        _clear.rightAnchor.constraint(equalTo: _done.leftAnchor, constant: -10).isActive = true
        _clear.widthAnchor.constraint(equalToConstant: 60).isActive = true
                
        _bold.centerYAnchor.constraint(equalTo: accessory.centerYAnchor).isActive = true
        _bold.leftAnchor.constraint(equalTo: accessory.safeAreaLayoutGuide.leftAnchor).isActive = true
        _bold.widthAnchor.constraint(equalToConstant: 80).isActive = true
        _bold.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        inputAccessoryView = accessory
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        var rect = super.caretRect(for: position)
        rect.size.width = caret
        return rect
    }
    
    @objc private func bold() {
        insertText("#")
    }
    
    @objc private func clear() {
        text = ""
        delegate?.textViewDidChange?(self)
    }
}
