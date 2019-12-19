import Foundation

extension Date {
    var interval: String {
        if #available(OSX 10.15, *) {
            return RelativeDateTimeFormatter().localizedString(for: self, relativeTo: .init())
        }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = Calendar.current.dateComponents([.day], from: self, to: .init()).day! == 0 ? .none : .short
        return formatter.string(from: self)
    }
}
