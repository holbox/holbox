import UIKit
import NaturalLanguage

final class Project: UIView {
    weak var top: NSLayoutConstraint! { didSet { top.isActive = true } }
    weak var left: NSLayoutConstraint! { didSet { left.isActive = true } }
    let order: Int
    private weak var _delete: Image!
    private let index: Int

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
        let waiting = app.session.cards(index, list: 0)
        let done = app.session.cards(index, list: 1)
        return "\(waiting + done) " + .key("Project.tasks") + "\n"
            + "\(waiting) " + .key("Project.waiting") + "\n"
            + "\(done) " + .key("Project.done") + "\n"
    }
    
    private var _shopping: String {
        "\(app.session.cards(index, list: 0)) " + .key("Project.products") + "\n" +
            "\(app.session.cards(index, list: 1)) " + .key("Project.needed") + "\n"
    }
    
    private var _notes: String {
        let content = app.session.content(index, list: 0, card: 0)
        var paragraphs = 0, sentences = 0, lines = 0, words = 0
        content.enumerateSubstrings(in: content.startIndex..., options: .byParagraphs) { _, _, _, _ in paragraphs += 1 }
        content.enumerateSubstrings(in: content.startIndex..., options: .bySentences) { _, _, _, _ in sentences += 1 }
        content.enumerateSubstrings(in: content.startIndex..., options: .byLines) { _, _, _, _ in lines += 1 }
        content.enumerateSubstrings(in: content.startIndex..., options: .byWords) { _, _, _, _ in words += 1 }
        
        var string = ""
        if #available(iOS 13.0, *) {
            let tagger = NLTagger(tagSchemes: [.language, .sentimentScore])
            tagger.string = content
            
            switch tagger.tag(at: string.startIndex, unit: .document, scheme: .language).0?.rawValue {
            case "en":
                string += .key("Project.english") + "\n"
            case "de":
                string += .key("Project.german") + "\n"
            case "es":
                string += .key("Project.spanish") + "\n"
            case "fr":
                string += .key("Project.french") + "\n"
            default: break
            }
            
            let score = Double(tagger.tag(at: string.startIndex, unit: .paragraph, scheme: .sentimentScore).0?.rawValue ?? "0") ?? 0
            if score == 0 {
                string += .key("Project.neutral") + "\n"
            } else if score > 0 {
                string += .key("Project.positive") + "\n"
            } else {
                string += .key("Project.negative") + "\n"
            }
        }
        
        string += "\(paragraphs) " + .key("Project.paragraphs") + "\n"
        string += "\(sentences) " + .key("Project.sentences") + "\n"
        string += "\(lines) " + .key("Project.lines") + "\n"
        string += "\(words) " + .key("Project.words") + "\n"
        string += .key("Project.created") + " " + interval(.init(timeIntervalSince1970: TimeInterval(app.session.name(index, list: 0))!))
        return string + "\n"
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
        
        let label = Label(app.session.name(index), 18, .bold, UIColor(named: "haze")!)
        label.isAccessibilityElement = false
        addSubview(label)
        
        let info = Label(detail + .key("Project.modified") + " " + interval(app.session.time(index)), 14, .regular, UIColor(named: "haze")!)
        info.isAccessibilityElement = false
        addSubview(info)
        
        let _delete = Image("delete")
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
        
        var chart: Chart?
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
            self?.backgroundColor = UIColor(named: "haze")!.withAlphaComponent(0.3)
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
    
    private func interval(_ date: Date) -> String {
        if #available(iOS 13.0, *) {
            return RelativeDateTimeFormatter().localizedString(for: date, relativeTo: .init())
        }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = Calendar.current.dateComponents([.day], from: date, to: .init()).day! == 0 ? .none : .short
        return formatter.string(from: date)
    }
}
