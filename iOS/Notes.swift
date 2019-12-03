import UIKit

final class Notes: View, UITextViewDelegate {
    private weak var text: Text!
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
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

        text.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        text.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        text.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        text.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true

        refresh()
    }
    
    func textViewDidEndEditing(_: UITextView) {
        app.session.content(app.project, list: 0, card: 0, content: text.text)
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
}
