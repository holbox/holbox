import AppKit
import NaturalLanguage

final class Project: NSView {
    weak var top: NSLayoutConstraint! { didSet { top.isActive = true } }
    weak var left: NSLayoutConstraint! { didSet { left.isActive = true } }
    let order: Int
    private weak var _delete: Image!
    private let index: Int
    override var mouseDownCanMoveWindow: Bool { false }
    
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
        "\((0 ..< app.session.lists(index)).reduce(into: 0) { $0 += app.session.cards(index, list: $1) }) " + .key("Project.cards") + "\n"
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
        var paragraphs = 0, sentences = 0
        content.enumerateSubstrings(in: content.startIndex..., options: .byParagraphs) { _, _, _, _ in paragraphs += 1 }
        content.enumerateSubstrings(in: content.startIndex..., options: .bySentences) { _, _, _, _ in sentences += 1 }
        var string = ""
        if #available(OSX 10.15, *) {
            let tagger = NLTagger(tagSchemes: [.language, .sentimentScore])
            tagger.string = content
            switch tagger.tag(at: string.startIndex, unit: .document, scheme: .language).0?.rawValue {
            case "en":
                string += .key("Project.english") + "\n"
            case "de":
                string += .key("Project.german") + "\n"
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
        string += "\(content.components(separatedBy: .newlines).count) " + .key("Project.lines") + "\n"
        string += "\(content.components(separatedBy: .whitespacesAndNewlines).count) " + .key("Project.words") + "\n"
        string += .key("Project.created") + " " + interval(.init(timeIntervalSince1970: TimeInterval(app.session.name(index, list: 0))!))
        return string + "\n"
    }
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int, order: Int) {
        self.index = index
        self.order = order
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        setAccessibilityLabel(app.session.name(index))
        wantsLayer = true
        layer!.cornerRadius = 10
        layer!.backgroundColor = NSColor(named: "background")!.cgColor
        
        let label = Label(app.session.name(index), 18, .bold, NSColor(named: "haze")!)
        label.setAccessibilityElement(false)
        addSubview(label)
        
        let info = Label(detail + .key("Project.modified") + " " + interval(app.session.time(index)), 13, .regular, NSColor(named: "haze")!)
        info.setAccessibilityElement(false)
        addSubview(info)
        
        let _delete = Image("delete")
        _delete.alphaValue = 0
        addSubview(_delete)
        self._delete = _delete
        
        widthAnchor.constraint(equalToConstant: 200).isActive = true
        heightAnchor.constraint(equalToConstant: 220).isActive = true
        
        label.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -30).isActive = true
        
        info.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        info.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        info.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        
        _delete.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        _delete.topAnchor.constraint(equalTo: topAnchor).isActive = true
        _delete.widthAnchor.constraint(equalToConstant: 40).isActive = true
        _delete.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        var chart: Chart?
        
        switch app.session.mode(index) {
        case .kanban:
            chart = .Lines(index)
            (chart as! Chart.Lines).width = 8
            (chart as! Chart.Lines).space = 18
        case .todo:
            chart = .Todo(index)
        case .shopping:
            chart = .Shopping(index)
            (chart as! Chart.Shopping).width = 20
        default: break
        }
        
        if chart != nil {
            addSubview(chart!)
            
            chart!.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10).isActive = true
            chart!.bottomAnchor.constraint(equalTo: info.topAnchor, constant: -10).isActive = true
            chart!.rightAnchor.constraint(equalTo: rightAnchor, constant: -23).isActive = true
            chart!.leftAnchor.constraint(equalTo: leftAnchor, constant: 23).isActive = true
        }
        
        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
    }
    
    override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }
    
    override func mouseEntered(with: NSEvent) {
        super.mouseEntered(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            layer!.backgroundColor = NSColor(named: "haze")!.withAlphaComponent(0.4).cgColor
            _delete.alphaValue = 1
        }
    }
    
    override func mouseExited(with: NSEvent) {
        super.mouseExited(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            _delete.alphaValue = 0
            layer!.backgroundColor = NSColor(named: "background")!.cgColor
        }
    }
    
    override func mouseDown(with: NSEvent) {
        alphaValue = 0.4
        super.mouseDown(with: with)
    }
    
    override func mouseUp(with: NSEvent) {
        if bounds.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
            if _delete.frame.contains(convert(with.locationInWindow, from: nil)) {
                app.runModal(for: Delete.Project(index))
            } else {
                app.project = index
            }
        }
        alphaValue = 1
        super.mouseUp(with: with)
    }
    
    private func interval(_ date: Date) -> String {
        if #available(OSX 10.15, *) {
            return RelativeDateTimeFormatter().localizedString(for: date, relativeTo: .init())
        }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = Calendar.current.dateComponents([.day], from: date, to: .init()).day! == 0 ? .none : .short
        return formatter.string(from: date)
    }
}
