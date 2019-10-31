#if os(macOS)
    import AppKit
#endif
#if os(iOS)
    import UIKit
#endif

final class Storage: NSTextStorage {
    lazy var fonts = [String.Mode.plain: self.font!]
    override var string: String { storage.string }
    private let storage = NSTextStorage()
    
    override func processEditing() {
        super.processEditing()
        storage.removeAttribute(.font, range: .init(location: 0, length: storage.length))
        string.mark { (fonts[$0]!, .init($1, in: string)) }.forEach {
            storage.addAttribute(.font, value: $0.0, range: $0.1)
        }
        layoutManagers.first!.processEditing(for: self, edited: .editedAttributes, range: .init(), changeInLength: 0, invalidatedRange: .init(location: 0, length: storage.length))
    }
    
    override func addAttributes(_ attrs: [NSAttributedString.Key : Any] = [:], range: NSRange) {
        storage.addAttributes(attrs, range: range)
    }
    
    override func invalidateAttributes(in range: NSRange) {
        storage.invalidateAttributes(in: range)
    }
    
    override func enumerateAttribute(_ attrName: NSAttributedString.Key, in enumerationRange: NSRange, options: NSAttributedString.EnumerationOptions = [], using: (Any?, NSRange, UnsafeMutablePointer<ObjCBool>) -> Void) {
        storage.enumerateAttribute(attrName, in: enumerationRange, options: options, using: using)
    }
    
    override func attribute(_ attrName: NSAttributedString.Key, at: Int, effectiveRange: NSRangePointer?) -> Any? {
        storage.attribute(attrName, at: at, effectiveRange: effectiveRange)
    }
    
    override func attribute(_ attrName: NSAttributedString.Key, at: Int, longestEffectiveRange: NSRangePointer?, in rangeLimit: NSRange) -> Any? {
        storage.attribute(attrName, at: at, longestEffectiveRange: longestEffectiveRange, in: rangeLimit)
    }
    
    override func attributes(at location: Int, longestEffectiveRange: NSRangePointer?, in rangeLimit: NSRange) -> [NSAttributedString.Key : Any] {
        storage.attributes(at: location, longestEffectiveRange: longestEffectiveRange, in: rangeLimit)
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
