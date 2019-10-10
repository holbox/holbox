import Foundation

extension Data {
    mutating func add(_ date: Date) {
        Swift.withUnsafeBytes(of: UInt32(date.timeIntervalSince1970)) { append($0.bindMemory(to: UInt8.self).baseAddress!, count: 4) }
    }
    
    mutating func add(_ byte: Int) {
        append(UInt8(byte))
    }
    
    mutating func add(_ mode: Mode) {
        append(mode.rawValue)
    }
    
    mutating func add(_ perk: Perk) {
        append(perk.rawValue)
    }
    
    mutating func add(_ string: String) {
        let data = Data(string.utf8)
        Swift.withUnsafeBytes(of: UInt16(data.count)) { append($0.bindMemory(to: UInt8.self).baseAddress!, count: 2) }
        self += data
    }
    
    mutating func date() -> Date {
        let result = withUnsafeBytes { $0.baseAddress!.bindMemory(to: UInt32.self, capacity: 1)[0] }
        move(4)
        return .init(timeIntervalSince1970: .init(result))
    }
    
    mutating func byte() -> Int {
        let result = first!
        move(1)
        return .init(result)
    }
    
    mutating func mode() -> Mode {
        let result = first!
        move(1)
        return Mode(rawValue: result)!
    }
    
    mutating func perk() -> Perk {
        let result = first!
        move(1)
        return Perk(rawValue: result)!
    }
    
    mutating func string() -> String {
        let size = Int(withUnsafeBytes { $0.baseAddress!.bindMemory(to: UInt16.self, capacity: 1)[0] })
        let result = String(decoding: subdata(in: 2 ..< 2 + size), as: UTF8.self)
        move(size + 2)
        return result
    }
    
    private mutating func move(_ amount: Int) {
        if count > amount {
            self = advanced(by: amount)
        } else {
            self = .init()
        }
    }
}
