import UIKit

extension UIColor {
    static let haze = #colorLiteral(red: 0.7137254902, green: 0.7411764706, blue: 1, alpha: 1)
    static let background = #colorLiteral(red: 0.06274509804, green: 0.05490196078, blue: 0.1019607843, alpha: 1)
}

extension CGColor {
    static let haze = UIColor.haze.cgColor
    static let background = UIColor.background.cgColor
    static let clear = UIColor.clear.cgColor
}
