import UIKit

final class Project: UIView {
    weak var top: NSLayoutConstraint! { didSet { top.isActive = true } }
    weak var left: NSLayoutConstraint! { didSet { left.isActive = true } }
    let order: Int
    private weak var _delete: Image!
    private let index: Int
    private let formatter = NumberFormatter()

    private var detail: String {
        switch app.session.mode(index) {
        case .kanban: return _kanban
        case .todo: return _todo
        case .shopping: return _shopping
        case .notes: return _notes
        default: return ""
        }
    }
    
    private var _kanban: String {
        "\(app.session.lists(index)) " + .key("Project.columns") + "\n" +
        "\((0 ..< app.session.lists(index)).map { app.session.cards(index, list: $0) }.reduce(0, +)) " + .key("Project.cards") + "\n"
    }
    
    private var _todo: String {
        "\(app.session.cards(index, list: 0) + app.session.cards(index, list: 1)) " + .key("Project.tasks") + "\n"
            + "\(app.session.cards(index, list: 0)) " + .key("Project.waiting") + "\n"
            + "\(app.session.cards(index, list: 1)) " + .key("Project.done") + "\n"
    }
    
    private var _shopping: String {
        "\(app.session.cards(index, list: 2)) " + .key("Project.products") + "\n" +
            "\( (0 ..< app.session.cards(index, list: 2)).reduce(into: 0) { $0 += app.session.content(index, list: 2, card: $1) == "0" ? 1 : 0 } ) " + .key("Project.need") + "\n" +
            "\( (0 ..< app.session.cards(index, list: 2)).reduce(into: 0) { $0 += app.session.content(index, list: 2, card: $1) == "1" ? 1 : 0 } ) " + .key("Project.have") + "\n"
    }
    
    private var _notes: String {
        let content = app.session.content(index, list: 0, card: 0)
        return content.language + "\n" + content.sentiment + "\n" +
            formatter.string(from: .init(value: content.paragraphs))! + " " + .key("Project.paragraphs") + "\n" +
            formatter.string(from: .init(value: content.sentences))! + " " + .key("Project.sentences") + "\n" +
            formatter.string(from: .init(value: content.lines))! + " " + .key("Project.lines") + "\n" +
            formatter.string(from: .init(value: content.words))! + " " + .key("Project.words") + "\n" +
            formatter.string(from: .init(value: content.count))! + " " + .key("Project.characters") + "\n" +
            .key("Project.created") + " " + Date(timeIntervalSince1970: TimeInterval(app.session.name(index, list: 0))!).interval + "\n"
    }
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int, order: Int) {
        self.index = index
        self.order = order
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = app.session.name(index)
        layer.cornerRadius = 8
        clipsToBounds = true
        formatter.numberStyle = .decimal
        
        let label = Label(app.session.name(index), .bold(16), .haze())
        label.isAccessibilityElement = false
        addSubview(label)
        
        let info = Label(detail + .key("Project.modified") + " " + app.session.time(index).interval, .regular(12), .haze())
        info.isAccessibilityElement = false
        addSubview(info)
        
        let _delete = Image("clear")
        addSubview(_delete)
        self._delete = _delete
        
        widthAnchor.constraint(equalToConstant: 180).isActive = true
        heightAnchor.constraint(equalToConstant: 220).isActive = true
        
        label.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -40).isActive = true
        
        info.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
        info.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        info.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -15).isActive = true
        
        _delete.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        _delete.topAnchor.constraint(equalTo: topAnchor).isActive = true
        _delete.widthAnchor.constraint(equalToConstant: 50).isActive = true
        _delete.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        var chart: UIView?
        switch app.session.mode(index) {
        case .kanban: chart = Lines(index)
        case .todo: chart = Progress(index)
        case .shopping: chart = Cart(index)
        default: break
        }

        if chart != nil {
            addSubview(chart!)

            chart!.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20).isActive = true
            chart!.bottomAnchor.constraint(equalTo: info.topAnchor, constant: -20).isActive = true
            chart!.rightAnchor.constraint(equalTo: rightAnchor, constant: -18).isActive = true
            chart!.leftAnchor.constraint(equalTo: leftAnchor, constant: 18).isActive = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.backgroundColor = .haze(0.3)
        }
        super.touchesBegan(touches, with: with)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with: UIEvent?) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.backgroundColor = .clear
        }
        super.touchesCancelled(touches, with: with)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        app.window!.endEditing(true)
        let location = touches.first!.location(in: self)
        if bounds.contains(location) {
            if _delete.frame.contains(location) {
                UIView.animate(withDuration: 0.3, animations: { [weak self] in
                    self?._delete.alpha = 0
                }) { [weak self] _ in
                    self?._delete.alpha = 1
                }
                app.present(Delete.Project(index), animated: true)
            } else {
                app.project = index
            }
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.backgroundColor = .clear
        }
        super.touchesEnded(touches, with: with)
    }
}
