import Foundation
import Compression

final class Coder {
    func session(_ session: Session) -> Data {
        var result = Data()
        result.add(session.rating)
        result.add(session.perks.count)
        session.perks.forEach { result.add($0) }
        result += global(session)
        return result
    }
    
    func global(_ session: Session) -> Data {
        var result = Data()
        result.add(session.counter)
        session.projects.forEach {
            result.add($0.id)
            result.add($0.time)
        }
        return result
    }
    
    func project(_ project: Project) -> Data {
        var result = Data()
        result.add(project.mode)
        result.add(project.name)
        result.add(project.time)
        project.cards.forEach {
            result.add($0.0)
            result.add($0.1.count)
            $0.1.forEach {
                result.add($0)
            }
        }
        return compress(result)
    }
    
    func session(_ data: Data) -> Session {
        var data = data
        let result = Session()
        result.rating = data.date()
        result.perks = (0 ..< data.byte()).map { _ in data.perk() }
        let shared = global(data)
        result.counter = shared.0
        result.projects = shared.1.map {
            var project = Project()
            project.id = $0.0
            project.time = $0.1
            return project
        }
        return result
    }
    
    func global(_ data: Data) -> (Int, [(Int, Date)]) {
        var data = data
        var result = [(Int, Date)]()
        let counter = data.byte()
        while !data.isEmpty {
            result.append((data.byte(), data.date()))
        }
        return (counter, result)
    }
    
    func project(_ data: Data) -> Project {
        var data = decompress(data)
        var result = Project()
        result.mode = data.mode()
        result.name = data.string()
        result.time = data.date()
        while !data.isEmpty {
            result.cards.append((data.string(), (0 ..< data.byte()).map { _ in data.string() }))
        }
        return result
    }
    
    private func compress(_ data: Data) -> Data {
        data.withUnsafeBytes {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count * 10)
            let result = Data(bytes: buffer, count: compression_encode_buffer(buffer, data.count * 10, $0.bindMemory(to: UInt8.self).baseAddress!, data.count, nil, COMPRESSION_LZFSE))
            buffer.deallocate()
            return result
        }
    }

    private func decompress(_ data: Data) -> Data {
        data.withUnsafeBytes {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count * 10)
            let read = compression_decode_buffer(buffer, data.count * 10, $0.bindMemory(to: UInt8.self).baseAddress!, data.count, nil, COMPRESSION_LZFSE)
            let result = Data(bytes: buffer, count: read)
            buffer.deallocate()
            return result
        }
    }
}
