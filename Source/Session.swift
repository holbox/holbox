import Foundation

public final class Session {
    public var rate: Bool { Date() >= rating }
    var rating = Calendar.current.date(byAdding: .day, value: 2, to: .init())!
    
    public func rated() { rating = Calendar.current.date(byAdding: .month, value: 3, to: .init())! }
}
