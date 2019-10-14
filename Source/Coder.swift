import Foundation

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
        return try! (result as NSData).compressed(using: .lzfse) as Data
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
        var data = try! (data as NSData).decompressed(using: .lzfse) as Data
        var result = Project()
        result.mode = data.mode()
        result.name = data.string()
        result.time = data.date()
        while !data.isEmpty {
            result.cards.append((data.string(), (0 ..< data.byte()).map { _ in data.string() }))
        }
        return result
    }
}
