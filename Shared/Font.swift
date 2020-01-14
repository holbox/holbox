#if os(macOS)
import AppKit

extension NSFont {
    private static let source = "orptltxennid"
    
    class func light(_ size: CGFloat) -> NSFont {
        NSFont(name: source.reversed() + "-Light", size: size)!
    }
    
    class func regular(_ size: CGFloat) -> NSFont {
        NSFont(name: source.reversed() + "-Regular", size: size)!
    }
    
    class func medium(_ size: CGFloat) -> NSFont {
        NSFont(name: source.reversed() + "-Medium", size: size)!
    }
    
    class func bold(_ size: CGFloat) -> NSFont {
        NSFont(name: source.reversed() + "-Bold", size: size)!
    }
}
#endif
#if os(iOS)
import UIKit

extension UIFont {
    private static let source = "orptltxennid"
    
    class func light(_ size: CGFloat) -> UIFont {
        UIFont(name: source.reversed() + "-Light", size: UIFontMetrics.default.scaledValue(for: size))!
    }
    
    class func regular(_ size: CGFloat) -> UIFont {
        UIFont(name: source.reversed() + "-Regular", size: UIFontMetrics.default.scaledValue(for: size))!
    }
    
    class func medium(_ size: CGFloat) -> UIFont {
        UIFont(name: source.reversed() + "-Medium", size: UIFontMetrics.default.scaledValue(for: size))!
    }
    
    class func bold(_ size: CGFloat) -> UIFont {
        UIFont(name: source.reversed() + "-Bold", size: UIFontMetrics.default.scaledValue(for: size))!
    }
}
#endif
