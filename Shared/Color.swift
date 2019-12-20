#if os(macOS)
import AppKit

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
#endif
#if os(iOS)
import UIKit

#endif
