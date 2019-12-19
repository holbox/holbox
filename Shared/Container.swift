#if os(macOS)
    import AppKit
#endif
#if os(iOS)
    import UIKit
#endif

final class Container: NSTextContainer {
    private let storage: NSTextStorage
    
    required init(coder: NSCoder) { fatalError() }
    init(_ storage: NSTextStorage) {
        self.storage = storage
        super.init(size: .zero)
        let layout = Layout()
        layout.delegate = layout
        layout.addTextContainer(self)
        storage.addLayoutManager(layout)
        lineBreakMode = .byTruncatingTail
    }
}
