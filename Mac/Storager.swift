import AppKit

class Storager: NSTextStorage {
    var fonts = [String.Mode: (NSFont, NSColor)]()
    let storage = NSTextStorage()
}
