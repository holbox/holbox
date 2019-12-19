#if os(macOS)
    import AppKit
#endif
#if os(iOS)
    import UIKit
#endif

final class Storage: NSTextStorage {
    var fonts = [.plain: (NSFont(name: "Rubik-Regular", size: 14)!, .white),
                 .emoji: (NSFont(name: "Rubik-Regular", size: 24)!, .white),
                 .bold: (NSFont(name: "Rubik-Bold", size: 22)!, .white),
                 .tag: (NSFont(name: "Rubik-Medium", size: 14)!, NSColor(named: "haze")!)] as [String.Mode: (NSFont, NSColor)]
    private let storage = NSTextStorage()
    override var string: String { storage.string }
    
    override func processEditing() {
        super.processEditing()
        storage.removeAttribute(.font, range: .init(location: 0, length: storage.length))
        storage.removeAttribute(.foregroundColor, range: .init(location: 0, length: storage.length))
        string.mark { (fonts[$0]!, NSRange($1, in: string)) }.forEach {
            storage.addAttributes([.font: $0.0.0, .foregroundColor: $0.0.1], range: $0.1)
        }
        layoutManagers.first!.processEditing(for: self, edited: .editedAttributes, range: .init(), changeInLength: 0, invalidatedRange: .init(location: 0, length: storage.length))
    }
    
    override func attributes(at: Int, effectiveRange: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        storage.attributes(at: at, effectiveRange: effectiveRange)
    }
    
    override func replaceCharacters(in range: NSRange, with: String) {
        storage.replaceCharacters(in: range, with: with)
        edited(.editedCharacters, range: range, changeInLength: (with as NSString).length - range.length)
    }

    override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        storage.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
    }

    override func removeAttribute(_ name: NSAttributedString.Key, range: NSRange) {
        storage.removeAttribute(name, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
    }

    override func addAttribute(_ name: NSAttributedString.Key, value: Any, range: NSRange) {
        storage.addAttribute(name, value: value, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
    }
}
