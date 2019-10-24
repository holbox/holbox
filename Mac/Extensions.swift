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
