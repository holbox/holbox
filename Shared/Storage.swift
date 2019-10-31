#if os(macOS)
    import AppKit
#endif
#if os(iOS)
    import UIKit
#endif

final class Storage: NSTextStorage {
    var size = 15
    override var string: String { storage.string }
    private let storage = NSTextStorage()
    
    override func attributes(at: Int, effectiveRange: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        storage.attributes(at: at, effectiveRange: effectiveRange)
    }
    
    override func replaceCharacters(in range: NSRange, with: String) {
        storage.replaceCharacters(in: range, with: with)
        edited(.editedCharacters, range: range, changeInLength: (with as NSString).length - range.length)
    }
    
    override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        storage.setAttributes(attrs, range: range)
    }
    
    override func processEditing() {
        super.processEditing()
        storage.removeAttribute(.font, range:NSMakeRange(0, storage.length))

        string.indices.forEach {
            guard let pos = $0.samePosition(in: string.unicodeScalars) else {
                print("none")
                return }
            if string.unicodeScalars[pos].properties.isEmojiPresentation {
                storage.addAttribute(.font, value: NSFont.systemFont(ofSize: 40, weight: .regular), range: NSRange($0 ..< string.index(after: $0), in: string))
            } else {
                storage.addAttribute(.font, value: NSFont.systemFont(ofSize: 5, weight: .regular), range: NSRange($0 ..< string.index(after: $0), in: string))
            }
        }
        
        
        
//        string.utf8.indices.reduce(into: [(14, NSRange(location: 0, length: 0))]) {
//            if string.utf8.index(after: <#T##String.UTF8View.Index#>)
//        }
//        string.indices.reduce(into: (string.startIndex, NSFont.systemFont(ofSize: 10), [(NSFont, Range)]()) ) {
//            if string.index(after:$1) == string.endIndex {
//                string.unicodeScalars[$0.0].properties.is
//
//                $0.2.append((string[$1] == "#" ? NSFont.systemFont(ofSize: 10) : $0.1, $0.0 ..< string.index(after:$1)))
//            } else if string[$1] == "#" || string[$1] == "\n" {
//                $0.2.append(($0.1, $0.0 ..< $1))
//                $0.0 = $1
//                $0.1 = string[$1] == "#" ? NSFont.systemFont(ofSize: 10) : NSFont.systemFont(ofSize: 10)
//            } }.2.forEach { storage.addAttribute(.font, value:$0.0, range:NSRange($0.1, in:string)) }
    }
}
