import UIKit

final class Column: UIView {
    let index: Int
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int) {
        self.index = index
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let name = UILabel()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.font = .monospacedSystemFont(ofSize: 20, weight: .bold)
        name.text = app.session.name(app.project, list: index)
        name.isAccessibilityElement = true
        name.accessibilityTraits = .staticText
        name.accessibilityLabel = .key("Column")
        name.accessibilityValue = app.session.name(app.project, list: index)
        addSubview(name)
        
        rightAnchor.constraint(greaterThanOrEqualTo: name.rightAnchor, constant: 70).isActive = true
        bottomAnchor.constraint(equalTo: name.bottomAnchor).isActive = true
        name.leftAnchor.constraint(equalTo: leftAnchor, constant: 70).isActive = true
        name.topAnchor.constraint(equalTo: topAnchor).isActive = true
    }
}
