import UIKit

final class Notes: View, UITextViewDelegate {
    private weak var text: Text!
    private weak var bottom: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        
        let border = Border()
        addSubview(border)
        
        let _pdf = Control("PDF", self, #selector(pdf(_:)), UIColor(named: "haze")!, .black)
        addSubview(_pdf)
        
        let text = Text()
        text.bounces = true
        text.alwaysBounceVertical = true
        text.textContainerInset = .init(top: 20, left: 20, bottom: 30, right: 20)
        text.accessibilityLabel = .key("Note")
        text.font = .systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 18), weight: .regular)
        (text.textStorage as! Storage).fonts = [
            .plain: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 18), weight: .medium), .white),
            .emoji: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 40), weight: .regular), .white),
            .bold: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 28), weight: .bold), UIColor(named: "haze")!),
            .tag: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 16), weight: .bold), UIColor(named: "haze")!)]
        text.delegate = self
        (text.layoutManager as! Layout).padding = 5
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
        
        text.bottomAnchor.constraint(equalTo: border.topAnchor).isActive = true
        text.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        text.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        text.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true

        refresh()
    }
    
    func textViewDidBeginEditing(_: UITextView) {
        bottom.constant = 1
        UIView.animate(withDuration: 1) { [weak self] in
            self?.layoutIfNeeded()
        }
    }
    
    func textViewDidEndEditing(_: UITextView) {
        app.session.content(app.project, list: 0, card: 0, content: text.text)
        bottom.constant = -60
        UIView.animate(withDuration: 1.5) { [weak self] in
            self?.layoutIfNeeded()
        }
    }
    
    override func refresh() {
        text.text = app.session.content(app.project, list: 0, card: 0)
    }
    
    override func found(_ ranges: [(Int, Int, NSRange)]) {
        text.textStorage.removeAttribute(.backgroundColor, range: .init(location: 0, length: text.text.utf16.count))
    }
    
    override func select(_ list: Int, _ card: Int, _ range: NSRange) {
        text.textStorage.removeAttribute(.backgroundColor, range: .init(location: 0, length: text.text.utf16.count))
        text.textStorage.addAttribute(.backgroundColor, value: UIColor(named: "haze")!.withAlphaComponent(0.6), range: range)
        var frame = text.layoutManager.boundingRect(forGlyphRange: range, in: text.textContainer)
        frame.origin.x = 0
        frame.origin.y = max(frame.origin.y - (((bounds.height - frame.size.height) / 2) - 45), 0)
        frame.size.width = bounds.width
        frame.size.height = bounds.height
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.text.scrollRectToVisible(frame, animated: true)
        }
    }
    
    @objc private func pdf(_ control: Control) {
        app.window!.endEditing(true)
        
        let string = app.session.content(app.project, list: 0, card: 0)
        let formatter = UISimpleTextPrintFormatter(attributedText: string.mark {
            switch $0 {
            case .plain: return .init(string: .init(string[$1]), attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .regular)])
            case .bold: return .init(string: .init(string[$1].dropFirst(2)), attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .bold)])
            case .emoji: return .init(string: .init(string[$1]), attributes: [.font: UIFont.systemFont(ofSize: 26, weight: .regular)])
            case .tag: return .init(string: .init(string[$1]), attributes: [.font: UIFont.systemFont(ofSize: 10, weight: .medium)])
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
            let activity = UIActivityViewController(activityItems:[url], applicationActivities:nil)
            activity.popoverPresentationController?.sourceView = control
            app.present(activity, animated: true)
        } catch {
            app.alert(.key("Error"), message: error.localizedDescription)
        }
    }
}
