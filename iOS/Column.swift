import UIKit

final class Column: UIView {
    private let index: Int
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int) {
        self.index = index
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let name = Label(app.session.name(app.project, list: index), 20, .bold, .white)
        name.accessibilityLabel = .key("Column")
        name.accessibilityValue = app.session.name(app.project, list: index)
        name.alpha = 0.2
        addSubview(name)
        
        rightAnchor.constraint(greaterThanOrEqualTo: name.rightAnchor, constant: 40).isActive = true
        bottomAnchor.constraint(equalTo: name.bottomAnchor, constant: 25).isActive = true
        name.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
        name.topAnchor.constraint(equalTo: topAnchor, constant: 25).isActive = true
    }
}
