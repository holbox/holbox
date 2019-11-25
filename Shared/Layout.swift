#if os(macOS)
    import AppKit
#endif
#if os(iOS)
    import UIKit
#endif

final class Layout: NSLayoutManager, NSLayoutManagerDelegate {
    var padding = CGFloat()
    var owns = false
    
#if os(macOS)
    override func layoutManagerOwnsFirstResponder(in window: NSWindow) -> Bool {
        owns ? owns : super.layoutManagerOwnsFirstResponder(in: window)
    }
#endif
    
    func layoutManager(_: NSLayoutManager, shouldSetLineFragmentRect: UnsafeMutablePointer<CGRect>,
                       lineFragmentUsedRect: UnsafeMutablePointer<CGRect>, baselineOffset: UnsafeMutablePointer<CGFloat>,
                       in: NSTextContainer, forGlyphRange: NSRange) -> Bool {
        baselineOffset.pointee = baselineOffset.pointee + padding
        shouldSetLineFragmentRect.pointee.size.height += padding + padding
        lineFragmentUsedRect.pointee.size.height += padding + padding
        return true
    }
    
    override func setExtraLineFragmentRect(_ rect: CGRect, usedRect: CGRect, textContainer: NSTextContainer) {
        var rect = rect
        var used = usedRect
        rect.size.height += padding + padding
        used.size.height += padding + padding
        super.setExtraLineFragmentRect(rect, usedRect: used, textContainer: textContainer)
    }
}
