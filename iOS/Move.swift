import UIKit

final class Move: UIViewController {
    private weak var card: Card?
    
    required init?(coder: NSCoder) { nil }
    init(_ card: Card) {
        super.init(nibName: nil, bundle: nil)
        self.card = card
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
