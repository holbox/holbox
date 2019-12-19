#if os(macOS)
import AppKit

extension NSColor {
    static func haze(_ alpha: CGFloat = 1) -> NSColor {
        alpha == 1 ? NSColor(named: "haze")! : NSColor(named: "haze")!.withAlphaComponent(alpha)
    }
    
    static func background(_ alpha: CGFloat = 1) -> NSColor {
        alpha == 1 ? NSColor(named: "background")! : NSColor(named: "background")!.withAlphaComponent(alpha)
    }
}

extension CGColor {
    static func haze(_ alpha: CGFloat = 1) -> CGColor {
        NSColor.haze(alpha).cgColor
    }
    
    static func background(_ alpha: CGFloat = 1) -> CGColor {
        NSColor.background(alpha).cgColor
    }
}
#endif
#if os(iOS)
import UIKit

#endif
