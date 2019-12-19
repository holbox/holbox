import AppKit

extension NSImage {
    func tint(_ color: NSColor) -> NSImage {
        let image = copy() as! NSImage
        image.lockFocus()
        color.set()
        NSRect(origin: .init(), size: image.size).fill(using: .sourceAtop)
        image.unlockFocus()
        return image
    }
}

extension NSColor {
    static func haze(_ alpha: CGFloat = 1) -> NSColor {
        alpha == 1 ? NSColor(named: "haze")! : NSColor(named: "haze")!.withAlphaComponent(alpha)
    }
}

extension CGColor {
    static func haze(_ alpha: CGFloat = 1) -> CGColor {
        NSColor.haze(alpha).cgColor
    }
}

extension NSFont {
    static func font(_ font: Font, _ size: CGFloat) -> NSFont {
        NSFont(name: font.rawValue, size: size)!
    }
}
