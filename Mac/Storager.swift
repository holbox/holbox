import AppKit

class Storager: NSTextStorage {
    var fonts = [.plain: (NSFont(name: "Rubik-Regular", size: 14)!, .white),
                 .emoji: (NSFont(name: "Rubik-Regular", size: 24)!, .white),
                 .bold: (NSFont(name: "Rubik-Bold", size: 22)!, .white),
                 .tag: (NSFont(name: "Rubik-Medium", size: 14)!, NSColor(named: "haze")!)] as [String.Mode: (NSFont, NSColor)]
    let storage = NSTextStorage()
}
