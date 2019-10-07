import Foundation
import Compression

final class Coder {
    func session(_ session: Session) -> Data {
        var result = Data()
        result.add(session.rating)
        result += shared(session)
        return result
    }
    
    func shared(_ session: Session) -> Data {
        var result = Data()
        result.add(session.counter)
        session.projects.forEach {
            result.add($0.id)
            result.add($0.time)
        }
        return result
    }
    
    func session(_ data: Data) -> Session {
        var data = data
        let result = Session()
        result.rating = data.date()
        result.overwrite(shared(data))
        return result
    }
    
    func shared(_ data: Data) -> (Int, [(Int, Date)]) {
        var data = data
        var result = [(Int, Date)]()
        let counter = data.byte()
        while !data.isEmpty {
            result.append((data.byte(), data.date()))
        }
        return (counter, result)
    }
    
    private func code(_ data: Data) -> Data {
        data.withUnsafeBytes {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count * 10)
            let result = Data(bytes: buffer, count: compression_encode_buffer(buffer, data.count * 10, $0.bindMemory(to: UInt8.self).baseAddress!, data.count, nil, COMPRESSION_LZMA))
            buffer.deallocate()
            print("size: \(result.count); gain: \(data.count - result.count)")
            return result
        }
    }

    private func decode(_ data: Data) -> Data {
        data.withUnsafeBytes {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count * 10)
            let read = compression_decode_buffer(buffer, data.count * 10, $0.bindMemory(to: UInt8.self).baseAddress!, data.count, nil, COMPRESSION_LZMA)
            let result = Data(bytes: buffer, count: read)
            buffer.deallocate()
            return result
        }
    }
}
