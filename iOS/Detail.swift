import UIKit

final class Detail: UIView {
    private final class Item: UIView {
        private weak var label: Label!
        private let index: Int
        
        required init?(coder: NSCoder) { nil }
        init(_ index: Int) {
            self.index = index
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            isAccessibilityElement = true
            accessibilityTraits = .button
            accessibilityLabel = app.session.name(index)
            layer.cornerRadius = 8
            
            let label = Label(app.session.name(index), 16, .bold, .white)
            addSubview(label)
            self.label = label
            
            heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        }
        
        override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
            backgroundColor = .haze
            label.textColor = .black
            super.touchesBegan(touches, with: with)
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
            if bounds.contains(touches.first!.location(in: self)) {
                app.main.project(index)
            } else {
                backgroundColor = .clear
                label.textColor = .white
            }
            super.touchesEnded(touches, with: with)
        }
    }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let scroll = Scroll()
        addSubview(scroll)
        
        let _add = Button("plus", target: self, action: #selector(add))
        addSubview(_add)
        
        let image = Image("detail.\(app.mode.rawValue)")
        image.contentMode = .scaleAspectFit
        scroll.add(image)
        
        let title = Label(.key("Detail.title.\(app.mode.rawValue)"), 30, .bold, .init(white: 1, alpha: 0.3))
        scroll.add(title)
        
        let border = Border()
        scroll.add(border)
        
        if app.session.projects(app.mode).isEmpty {
            let empty = Label(.key("Detail.empty.\(app.mode.rawValue)"), 14, .light, .init(white: 1, alpha: 0.4))
            scroll.add(empty)
            
            empty.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 20).isActive = true
            empty.leftAnchor.constraint(equalTo: scroll.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
            
            scroll.bottom.constraint(greaterThanOrEqualTo: empty.bottomAnchor, constant: 40).isActive = true
        } else {
            var top: NSLayoutYAxisAnchor?
            app.session.projects(app.mode).forEach {
                let item = Item($0)
                scroll.add(item)
                
                item.leftAnchor.constraint(equalTo: scroll.safeAreaLayoutGuide.leftAnchor, constant: 40).isActive = true
                item.widthAnchor.constraint(equalTo: scroll.safeAreaLayoutGuide.widthAnchor, constant: -80).isActive = true
                
                if top == nil {
                    item.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
                } else {
                    let border = Border()
                    scroll.add(border)
                    
                    border.leftAnchor.constraint(equalTo: scroll.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
                    border.rightAnchor.constraint(equalTo: scroll.safeAreaLayoutGuide.rightAnchor, constant: -60).isActive = true
                    border.topAnchor.constraint(equalTo: top!).isActive = true
                    
                    item.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
                }
                
                top = item.bottomAnchor
            }
            scroll.bottom.constraint(greaterThanOrEqualTo: top!, constant: 40).isActive = true
        }
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.right.constraint(equalTo: rightAnchor).isActive = true
        
        _add.widthAnchor.constraint(equalToConstant: 70).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 70).isActive = true
        _add.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        _add.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        
        image.widthAnchor.constraint(equalToConstant: 120).isActive = true
        image.heightAnchor.constraint(equalToConstant: 120).isActive = true
        image.topAnchor.constraint(equalTo: scroll.top, constant: 80).isActive = true
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        title.leftAnchor.constraint(equalTo: scroll.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        title.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 50).isActive = true
        
        border.leftAnchor.constraint(equalTo: scroll.content.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        border.rightAnchor.constraint(equalTo: scroll.content.safeAreaLayoutGuide.rightAnchor, constant: -60).isActive = true
        border.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20).isActive = true
    }
    
    @objc private func add() {
        app.present(Add(), animated: true)
    }
}
