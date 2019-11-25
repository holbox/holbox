import Foundation
import Compression

final class Coder {
    func session(_ session: Session) -> Data {
        var result = Data()
        result += settings(session.settings)
        result.add(session.rating)
        result.add(session.perks.count)
        session.perks.forEach { result.add($0) }
        result += global(session)
        return result
    }
    
    func global(_ session: Session) -> Data {
        var result = Data()
        session.items.forEach {
            result.add($0.0)
            result.add($0.1.time)
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
    
    func session(_ session: Session, data: Data) {
        var data = data
        session.settings = settings(&data)
        session.rating = data.date()
        session.perks = (0 ..< data.byte()).map { _ in data.perk() }
        let shared = global(data)
        session.items = shared.reduce(into: [:]) {
            var project = Project()
            project.time = $1.1
            $0[$1.0] = project
        }
    }
    
    func global(_ data: Data) -> [(Int, Date)] {
        var data = data
        var result = [(Int, Date)]()
        while !data.isEmpty {
            result.append((data.byte(), data.date()))
        }
        return result
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
    
    private func settings(_ settings: Settings) -> Data {
        var result = Array(repeating: UInt8(), count: Settings.size)
        result[0] = settings.spell ? 1 : 0
        return .init(result)
    }
    
    private func settings(_ data: inout Data) -> Settings {
        var settings = Settings()
        settings.spell = data[0] == 1
        data.move(Settings.size)
        return settings
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
