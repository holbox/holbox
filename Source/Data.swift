import Foundation

extension Data {
    mutating func add(_ date: Date) {
        Swift.withUnsafeBytes(of: UInt32(date.timeIntervalSince1970)) { append($0.bindMemory(to: UInt8.self).baseAddress!, count: 4) }
    }
    
    mutating func add(_ byte: Int) {
        append(UInt8(byte))
    }
    
    mutating func add(_ mode: Session.Mode) {
        append(mode.rawValue)
    }
    
    mutating func date() -> Date {
        let date = withUnsafeBytes { $0.baseAddress!.bindMemory(to: UInt32.self, capacity: 1)[0] }
        move(4)
        return .init(timeIntervalSince1970: .init(date))
    }
    
    mutating func byte() -> Int {
        let byte = first!
        move(1)
        return .init(byte)
    }
    
    mutating func mode() -> Session.Mode {
        let mode = first!
        move(1)
        return Session.Mode(rawValue: mode)!
    }
    
    private mutating func move(_ amount: Int) {
        if count > amount {
            self = advanced(by: amount)
        } else {
            self = .init()
        }
    }
}
