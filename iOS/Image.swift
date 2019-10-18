import UIKit

final class Image: UIImageView {
    required init?(coder: NSCoder) { nil }
    init(_ image: String, template: Bool = false) {
        super.init(image: template ? UIImage(named: image)!.withRenderingMode(.alwaysTemplate) : UIImage(named: image)!)
        translatesAutoresizingMaskIntoConstraints = false
        contentMode = .center
        clipsToBounds = true
    }
}
