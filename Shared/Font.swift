#if os(macOS)
import AppKit

extension NSFont {
    class func light(_ size: CGFloat) -> NSFont {
        NSFont(name: "Rubik-Light", size: size)!
    }
    
    class func regular(_ size: CGFloat) -> NSFont {
        NSFont(name: "Rubik-Regular", size: size)!
    }
    
    class func medium(_ size: CGFloat) -> NSFont {
        NSFont(name: "Rubik-Medium", size: size)!
    }
    
    class func bold(_ size: CGFloat) -> NSFont {
        NSFont(name: "Rubik-Bold", size: size)!
    }
}
#endif
#if os(iOS)
import UIKit

extension UIFont {
    private static let source = "orptltxennid"
    
    class func light(_ size: CGFloat) -> UIFont {
        UIFont(name: "Rubik-Light", size: UIFontMetrics.default.scaledValue(for: size))!
    }
    
    class func regular(_ size: CGFloat) -> UIFont {
        UIFont(name: "Rubik-Regular", size: UIFontMetrics.default.scaledValue(for: size))!
    }
    
    class func medium(_ size: CGFloat) -> UIFont {
        UIFont(name: "Rubik-Medium", size: UIFontMetrics.default.scaledValue(for: size))!
    }
    
    class func bold(_ size: CGFloat) -> UIFont {
        UIFont(name: "Rubik-Bold", size: UIFontMetrics.default.scaledValue(for: size))!
    }
}
#endif
