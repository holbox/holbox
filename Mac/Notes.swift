import AppKit

final class Notes: View, NSTextViewDelegate {
    private weak var text: Text!
    private weak var scroll: Scroll!
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let border = Border()
        addSubview(border)
        
        let _pdf = Control("PDF", self, #selector(pdf), NSColor(named: "haze")!.cgColor, .black)
        addSubview(_pdf)
        
        let text = Text(.Fix(), Active())
        text.textContainerInset.width = 40
        text.textContainerInset.height = 30
        text.setAccessibilityLabel(.key("Note"))
        text.font = NSFont(name: "Times New Roman", size: 18)
        (text.textStorage as! Storage).fonts = [.plain: (.systemFont(ofSize: 18, weight: .regular), .white),
                                               .emoji: (NSFont(name: "Times New Roman", size: 40)!, .white),
                                               .bold: (.systemFont(ofSize: 28, weight: .bold), NSColor(named: "haze")!),
                                               .tag: (.systemFont(ofSize: 16, weight: .bold), NSColor(named: "haze")!)]
        text.tab = true
        text.intro = true
        (text.layoutManager as! Layout).owns = true
        (text.layoutManager as! Layout).padding = 5
        text.delegate = self
        scroll.add(text)
        self.text = text

        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        scroll.bottomAnchor.constraint(equalTo: border.topAnchor).isActive = true
        scroll.right.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: border.topAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: text.bottomAnchor, constant: 10).isActive = true
        
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        border.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -60).isActive = true
        
        _pdf.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 10).isActive = true
        _pdf.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        _pdf.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        text.topAnchor.constraint(equalTo: scroll.top).isActive = true
        text.leftAnchor.constraint(greaterThanOrEqualTo: scroll.left).isActive = true
        text.rightAnchor.constraint(lessThanOrEqualTo: scroll.right).isActive = true
        text.widthAnchor.constraint(lessThanOrEqualToConstant: 900).isActive = true
        text.bottomAnchor.constraint(greaterThanOrEqualTo: border.topAnchor).isActive = true
        text.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        
        let width = text.widthAnchor.constraint(equalToConstant: 900)
        width.priority = .defaultLow
        width.isActive = true

        refresh()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.window!.makeFirstResponder(self.text)
        }
    }
    
    func textDidEndEditing(_: Notification) {
        text.isEditable = false
        app.session.content(app.project, list: 0, card: 0, content: text.string)
    }
    
    override func refresh() {
        text.string = app.session.content(app.project, list: 0, card: 0)
    }
    
    override func found(_ ranges: [(Int, Int, NSRange)]) {
        if ranges.isEmpty {
            text.setSelectedRange(.init())
        } else {
            text.setSelectedRanges(ranges.map { $0.2 as NSValue }, affinity: .downstream, stillSelecting: true)
        }
    }
    
    override func select(_ list: Int, _ card: Int, _ range: NSRange) {
        text.showFindIndicator(for: range)
        scroll.center(scroll.contentView.convert(text.layoutManager!.boundingRect(forGlyphRange: range, in: text.textContainer!), from: text))
    }
    
    @objc private func pdf() {
        let save = NSSavePanel()
        save.nameFieldStringValue = app.session.name(app.project)
        save.allowedFileTypes = ["pdf"]
        save.beginSheetModal(for: window!) {
            if $0 == .OK {
                let view = NSView()
                view.translatesAutoresizingMaskIntoConstraints = false
                
                let string = app.session.content(app.project, list: 0, card: 0)
                let label = Label(string.mark {
                    switch $0 {
                    case .plain: return (.init(string[$1]), 12, .regular, .black)
                    case .bold: return (.init(string[$1]), 20, .bold, .black)
                    case .emoji: return (.init(string[$1]), 26, .regular, .black)
                    case .tag: return (.init(string[$1]), 10, .medium, .black)
                    }
                })
                view.addSubview(label)
                
                label.widthAnchor.constraint(equalToConstant: 470).isActive = true
                label.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
                label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                
                view.rightAnchor.constraint(equalTo: label.rightAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
                
                view.layoutSubtreeIfNeeded()
                
                let print = NSPrintOperation(view: view, printInfo: .init(dictionary: [.jobSavingURL: save.url!]))
                print.printInfo.paperSize = .init(width: 612, height: 792)
                print.printInfo.jobDisposition = .save
                print.printInfo.topMargin = 71
                print.printInfo.leftMargin = 71
                print.printInfo.rightMargin = 71
                print.printInfo.bottomMargin = 71
                print.printInfo.isVerticallyCentered = false
                print.printInfo.isHorizontallyCentered = false
                print.printInfo.verticalPagination = .automatic
                print.showsPrintPanel = false
                print.showsProgressPanel = false
                print.run()
            }
        }
    }
}
