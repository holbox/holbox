import UIKit

final class Columner: UIViewController {
    private weak var column: Column!
    private var _delete: (Circle, NSLayoutConstraint)!
    private var _edit: (Circle, NSLayoutConstraint)!
    
    required init?(coder: NSCoder) { nil }
    init(_ column: Column) {
        super.init(nibName: nil, bundle: nil)
        self.column = column
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .init(white: 0, alpha: 0.8)
        
        let _done = Circle(.key("Columner.done"), self, #selector(close), .haze(), .black)
        view.addSubview(_done)
        
        let _delete = Circle(image: "trash", self, #selector(remove), .haze(), .black)
        _delete.accessibilityLabel = .key("Move.delete")
        view.addSubview(_delete)
        
        let _edit = Circle(image: "write", self, #selector(edit), .haze(), .black)
        _edit.accessibilityLabel = .key("Move.edit")
        view.addSubview(_edit)
        
        _done.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        _done.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        _delete.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self._delete = (_delete, _delete.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        self._delete.1.isActive = true
        
        _edit.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self._edit = (_edit, _edit.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        self._edit.1.isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.layoutIfNeeded()
        _delete.1.constant = -100
        _edit.1.constant = 100
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _delete.1.constant = 0
        _edit.1.constant = 0
        UIView.animate(withDuration: 0.35) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc private func close() {
        presentingViewController!.dismiss(animated: true)
    }
    
    @objc private func remove() {
        presentingViewController!.dismiss(animated: true) { [weak self] in
            guard let column = self?.column else { return }
            app.present(Delete.List(column.index), animated: true)
        }
    }
    
    @objc private func edit() {
        presentingViewController!.dismiss(animated: true) { [weak self] in
            self?.column?.edit()
        }
    }
}
