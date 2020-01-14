import UIKit

final class Notes: View, UITextViewDelegate {
    private weak var text: Text!
    private weak var stats: Label!
    private weak var bottom: NSLayoutConstraint!
    private let formatter = NumberFormatter()
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        formatter.numberStyle = .decimal
        
        let border = Border.horizontal()
        addSubview(border)
        
        let _pdf = Control("PDF", self, #selector(pdf(_:)), .haze(), .black)
        addSubview(_pdf)
        
        let stats = Label("", .regular(14), .haze())
        stats.numberOfLines = 3
        stats.lineBreakMode = .byTruncatingHead
        addSubview(stats)
        self.stats = stats
        
        let text = Text(Storage())
        text.bounces = true
        text.textContainerInset = .init(top: 20, left: 20, bottom: 30, right: 20)
        text.accessibilityLabel = .key("Note")
        text.font = .regular(20)
        (text.textStorage as! Storage).attributes = [.plain: [.font: UIFont.regular(20), .foregroundColor: UIColor.white],
                                                     .emoji: [.font: UIFont.regular(30)],
                                                     .bold: [.font: UIFont.bold(24), .foregroundColor: UIColor.haze()],
                                                     .tag: [.font: UIFont.medium(16), .foregroundColor: UIColor.haze()]]
        text.delegate = self
        (text.layoutManager as! Layout).padding = 6
        text.caret = 4
        addSubview(text)
        self.text = text
        
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bottom = border.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -60)
        bottom.isActive = true
        
        _pdf.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        _pdf.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        _pdf.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        stats.centerYAnchor.constraint(equalTo: _pdf.centerYAnchor).isActive = true
        stats.rightAnchor.constraint(lessThanOrEqualTo: _pdf.leftAnchor, constant: -10).isActive = true
        stats.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        
        text.bottomAnchor.constraint(equalTo: border.topAnchor).isActive = true
        text.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        text.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        text.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true

        refresh()
    }
    
    func textViewDidChange(_: UITextView) {
        app.session.content(app.project, list: 0, card: 0, content: text.text)
    }
    
    func textViewDidBeginEditing(_: UITextView) {
        bottom.constant = 1
        UIView.animate(withDuration: 1) { [weak self] in
            self?.layoutIfNeeded()
        }
    }
    
    func textViewDidEndEditing(_: UITextView) {
        bottom.constant = -60
        update()
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.layoutIfNeeded()
        }
    }
    
    override func refresh() {
        text.text = app.session.content(app.project, list: 0, card: 0)
        update()
    }
    
    override func found(_ ranges: [(Int, Int, NSRange)]) {
        text.textStorage.removeAttribute(.backgroundColor, range: .init(location: 0, length: text.text.utf16.count))
    }
    
    override func select(_ list: Int, _ card: Int, _ range: NSRange) {
        text.textStorage.removeAttribute(.backgroundColor, range: .init(location: 0, length: text.text.utf16.count))
        text.textStorage.addAttribute(.backgroundColor, value: UIColor.haze(0.6), range: range)
        var frame = text.layoutManager.boundingRect(forGlyphRange: range, in: text.textContainer)
        frame.origin.x = 0
        frame.origin.y = max(frame.origin.y - (((bounds.height - frame.size.height) / 2) - 45), 0)
        frame.size.width = bounds.width
        frame.size.height = bounds.height
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.text.scrollRectToVisible(frame, animated: true)
        }
    }
    
    private func update() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self, app.project != nil else { return }
            let text = app.session.content(app.project, list: 0, card: 0)
            let string = text.language + ", " + text.sentiment + ", " +
                self.formatter.string(from: .init(value: text.paragraphs))! + " " + .key("Project.paragraphs") + ",\n" +
                self.formatter.string(from: .init(value: text.sentences))! + " " + .key("Project.sentences") + ", " +
                self.formatter.string(from: .init(value: text.lines))! + " " + .key("Project.lines") + ", " +
                self.formatter.string(from: .init(value: text.words))! + " " + .key("Project.words") + ", " +
                self.formatter.string(from: .init(value: text.count))! + " " + .key("Project.characters") + "."
            DispatchQueue.main.async { [weak self] in
                self?.stats.text = string
            }
        }
    }
    
    @objc private func pdf(_ control: Control) {
        app.window!.endEditing(true)
        
        let string = app.session.content(app.project, list: 0, card: 0)
        let formatter = UISimpleTextPrintFormatter(attributedText: string.mark {
            switch $0 {
            case .plain: return .init(string: .init(string[$1]), attributes: [.font: UIFont.regular(12)])
            case .bold: return .init(string: .init(string[$1].dropFirst(2)), attributes: [.font: UIFont.bold(18)])
            case .emoji: return .init(string: .init(string[$1]), attributes: [.font: UIFont.regular(26)])
            case .tag: return .init(string: .init(string[$1]), attributes: [.font: UIFont.medium(10)])
            }
        }.reduce(into: NSMutableAttributedString()) { $0.append($1) })
        formatter.color = .black
        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(formatter, startingAtPageAt: 0)
        let size = CGSize(width: 612, height: 792)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        renderer.setValue(NSValue(cgRect: rect), forKey: "paperRect")
        renderer.setValue(NSValue(cgRect: .init(x: 71, y: 71, width: size.width - 142, height: size.height - 142)), forKey: "printableRect")
        
        let data = NSMutableData()
        UIGraphicsBeginPDFContextToData(data, rect, nil)
        renderer.prepare(forDrawingPages: .init(location: 0, length: renderer.numberOfPages))
        (0 ..< renderer.numberOfPages).forEach {
            UIGraphicsBeginPDFPage()
            renderer.drawPage(at: $0, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext()
        
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(app.session.name(app.project) + ".pdf")
        do {
            try data.write(to: url, options: .atomic)
            let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            activity.popoverPresentationController?.sourceView = control
            app.present(activity, animated: true)
        } catch {
            app.alert(.key("Error"), message: error.localizedDescription)
        }
    }
}
