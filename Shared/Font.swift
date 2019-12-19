#if os(macOS)
import AppKit

extension NSFont {
    convenience init(light: CGFloat) {
        self.init(name: "Rubik-Light", size: light)!
    }
    
    convenience init(regular: CGFloat) {
        self.init(name: "Rubik-Regular", size: regular)!
    }
    
    convenience init(medium: CGFloat) {
        self.init(name: "Rubik-Medium", size: medium)!
    }
    
    convenience init(bold: CGFloat) {
        self.init(name: "Rubik-Bold", size: bold)!
    }
}
#endif
#if os(iOS)
import UIKit

#endif
