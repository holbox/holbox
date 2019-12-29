import UIKit

final class Columner: UIViewController {
    private weak var column: Column!
    private var _delete: NSLayoutConstraint!
    private var _done: NSLayoutConstraint!
    
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
        
        let _done = Circle("check", self, #selector(close), .haze(), .black)
        _done.accessibilityLabel = .key("Columner.done")
        view.addSubview(_done)
        
        let _delete = Circle("trash", self, #selector(remove), .haze(), .black)
        _delete.accessibilityLabel = .key("Columner.delete")
        view.addSubview(_delete)
        
        let _edit = Circle("write", self, #selector(edit), .haze(), .black)
        _edit.accessibilityLabel = .key("Columner.edit")
        view.addSubview(_edit)
        
        _edit.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        _edit.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        _done.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self._done = _done.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        self._done.isActive = true
        
        _delete.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self._delete = _delete.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        self._delete.isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.layoutIfNeeded()
        _delete.constant = -90
        _done.constant = 90
        UIView.animate(withDuration: 0.35) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _delete.constant = 0
        _done.constant = 0
        UIView.animate(withDuration: 0.25) { [weak self] in
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
