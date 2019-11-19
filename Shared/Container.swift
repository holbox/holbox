#if os(macOS)
    import AppKit
#endif
#if os(iOS)
    import UIKit
#endif

final class Container: NSTextContainer {
    private let storage = Storage()
    
    required init(coder: NSCoder) { fatalError() }
    init() {
        super.init(size: .zero)
        let layout = Layout()
        layout.delegate = layout
        layout.addTextContainer(self)
        storage.addLayoutManager(layout)
        lineBreakMode = .byTruncatingTail
    }
}

private final class Layout: NSLayoutManager, NSLayoutManagerDelegate {
    private let padding = CGFloat(4)
    
    func layoutManager(_: NSLayoutManager, shouldSetLineFragmentRect: UnsafeMutablePointer<CGRect>,
                       lineFragmentUsedRect: UnsafeMutablePointer<CGRect>, baselineOffset: UnsafeMutablePointer<CGFloat>,
                       in: NSTextContainer, forGlyphRange: NSRange) -> Bool {
        baselineOffset.pointee = baselineOffset.pointee + padding
        shouldSetLineFragmentRect.pointee.size.height += padding + padding
        lineFragmentUsedRect.pointee.size.height += padding + padding
        return true
    }
    
    override func fillBackgroundRectArray(_ rectArray: UnsafePointer<NSRect>, count: Int, forCharacterRange: NSRange, color: NSColor) {
        NSColor(named: "haze")!.withAlphaComponent(0.7).setFill()
        super.fillBackgroundRectArray(rectArray, count: count, forCharacterRange: forCharacterRange, color: color)
    }
    
    override func setExtraLineFragmentRect(_ rect: CGRect, usedRect: CGRect, textContainer: NSTextContainer) {
        var rect = rect
        var used = usedRect
        rect.size.height += padding + padding
        used.size.height += padding + padding
        super.setExtraLineFragmentRect(rect, usedRect: used, textContainer: textContainer)
    }
}
