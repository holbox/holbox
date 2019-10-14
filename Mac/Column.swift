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
        name.font = .monospacedSystemFont(ofSize: 20, weight: .bold)
        name.string = app.session.name(app.project, list: index)
        name.textContainer!.size.width = 400
        name.textContainer!.size.height = 45
        addSubview(name)
        self.name = name
        
        addSubview(name)
        
        var top: NSLayoutYAxisAnchor?
        (0 ..< app.session.cards(app.project, list: index)).forEach {
            let card = Card($0, column: index)
            addSubview(card)
            
            if top == nil {
                card.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 40).isActive = true
            } else {
                card.topAnchor.constraint(equalTo: top!, constant: 20).isActive = true
            }
            
            card.leftAnchor.constraint(equalTo: leftAnchor, constant: 80).isActive = true
            rightAnchor.constraint(greaterThanOrEqualTo: card.rightAnchor, constant: 80).isActive = true
            bottomAnchor.constraint(greaterThanOrEqualTo: card.bottomAnchor, constant: 20).isActive = true
            top = card.bottomAnchor
        }
        
        rightAnchor.constraint(greaterThanOrEqualTo: name.rightAnchor, constant: 70).isActive = true
        bottomAnchor.constraint(greaterThanOrEqualTo: name.bottomAnchor, constant: 50).isActive = true
        name.leftAnchor.constraint(equalTo: leftAnchor, constant: 70).isActive = true
        name.topAnchor.constraint(equalTo: topAnchor, constant: 120).isActive = true
        name.didChangeText()
        name.delegate = self
    }
    
    func textDidEndEditing(_: Notification) {
        app.session.name(app.project, list: index, name: name.string)
    }
}
