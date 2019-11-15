import UIKit

final class Column: UIView {
    private let index: Int
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int) {
        self.index = index
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let string = app.session.name(app.project, list: index)
        let name = Label(string.mark {
            switch $0 {
            case .plain: return (.init(string[$1]), 18, .bold, UIColor(named: "haze")!.withAlphaComponent(0.7))
            case .emoji: return (.init(string[$1]), 24, .regular, UIColor(named: "haze")!.withAlphaComponent(0.7))
            case .bold: return (.init(string[$1]), 20, .bold, UIColor(named: "haze")!.withAlphaComponent(0.7))
                case .tag: fatalError()
            }
        })
        name.accessibilityLabel = .key("Column")
        name.accessibilityValue = string
        name.numberOfLines = 1
        name.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        addSubview(name)
        
        let width = widthAnchor.constraint(equalToConstant: 0)
        width.priority = .defaultLow
        width.isActive = true
        
        rightAnchor.constraint(greaterThanOrEqualTo: name.rightAnchor, constant: 20).isActive = true
        bottomAnchor.constraint(equalTo: name.bottomAnchor, constant: 20).isActive = true
        name.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        name.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        name.widthAnchor.constraint(lessThanOrEqualToConstant: 350).isActive = true
    }
}
