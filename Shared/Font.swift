#if os(macOS)
import AppKit

extension NSFont {
    class func light(_ size: CGFloat) -> NSFont {
        NSFont(name: "SFProRounded-Light", size: size)!
    }
    
    class func regular(_ size: CGFloat) -> NSFont {
        NSFont(name: "SFProRounded-Regular", size: size)!
    }
    
    class func medium(_ size: CGFloat) -> NSFont {
        NSFont(name: "SFProRounded-Medium", size: size)!
    }
    
    class func bold(_ size: CGFloat) -> NSFont {
        NSFont(name: "SFProRounded-Bold", size: size)!
    }
}
#endif
#if os(iOS)
import UIKit

extension UIFont {
    class func light(_ size: CGFloat) -> UIFont {
        UIFont(name: "SFProRounded-Light", size: UIFontMetrics.default.scaledValue(for: size))!
    }
    
    class func regular(_ size: CGFloat) -> UIFont {
        UIFont(name: "SFProRounded-Regular", size: UIFontMetrics.default.scaledValue(for: size))!
    }
    
    class func medium(_ size: CGFloat) -> UIFont {
        UIFont(name: "SFProRounded-Medium", size: UIFontMetrics.default.scaledValue(for: size))!
    }
    
    class func bold(_ size: CGFloat) -> UIFont {
        UIFont(name: "SFProRounded-Bold", size: UIFontMetrics.default.scaledValue(for: size))!
    }
}
#endif
