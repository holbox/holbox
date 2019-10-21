import AppKit

final class Column: NSView, NSTextViewDelegate {
    let index: Int
    private weak var name: Text!
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int) {
        self.index = index
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let name = Text()
        name.setAccessibilityLabel(.key("Column"))
        name.font = .systemFont(ofSize: 20, weight: .bold)
        name.string = app.session.name(app.project, list: index)
        name.textContainer!.size.width = 400
        name.textContainer!.size.height = 45
        addSubview(name)
        self.name = name
        
        rightAnchor.constraint(greaterThanOrEqualTo: name.rightAnchor, constant: 70).isActive = true
        bottomAnchor.constraint(equalTo: name.bottomAnchor).isActive = true
        name.leftAnchor.constraint(equalTo: leftAnchor, constant: 70).isActive = true
        name.topAnchor.constraint(equalTo: topAnchor).isActive = true
        name.didChangeText()
        name.delegate = self
    }
    
    func textDidEndEditing(_: Notification) {
        app.session.name(app.project, list: index, name: name.string)
    }
}
