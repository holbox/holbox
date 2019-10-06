import Foundation
import Compression

final class Coder {
    func code(_ session: Session) -> Data {
        var result = Data()
        result.add(session.rating)
        result += code(session.global)
        return result
    }
    
    func code(_ global: Session.Global) -> Data {
        var result = Data()
        result.add(global.counter)
        result.append(contentsOf: global.projects.flatMap(code))
        return result
    }
    
    func session(_ data: Data) -> Session {
        var data = data
        let result = Session()
        result.rating = data.date()
        result.global = global(data)
        return result
    }
    
    func global(_ data: Data) -> Session.Global {
        var data = data
        var result = Session.Global()
        result.counter = data.byte()
        while !data.isEmpty {
            result.projects.append(project(&data))
        }
        return result
    }
    
    private func code(_ project: Session.Project) -> Data {
        var result = Data()
        result.add(project.id)
        result.add(project.mode)
        result.add(project.time)
        return result
    }
    
    private func project(_ data: inout Data) -> Session.Project {
        var result = Session.Project()
        result.id = data.byte()
        result.mode = data.mode()
        result.time = data.date()
        return result
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
