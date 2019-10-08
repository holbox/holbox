import Foundation

class Store {
    static var id = ""
    static let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Store")
    private static let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    private static let coder = Coder()
    var ubi = NSUbiquitousKeyValueStore.default
    var shared = Shared()
    
    func load(_ result: @escaping(Session) -> Void) {
        Store.queue.async { [weak self] in
            guard let self = self else { return }
            self.prepare()
            self.loadId()
            self.loadSession { _ in
                
            }
        }
    }
    
    func save(_ session: Session) {
        
    }
    
    func save(_ project: Project) {
        
    }
    
    func loadId() {
        if let id = try? String(decoding: Data(contentsOf: Store.url.appendingPathComponent("id")), as: UTF8.self) {
            Store.id = id
        } else {
            loadUbi()
            try! Data(Store.id.utf8).write(to: Store.url.appendingPathComponent("id"), options: .atomic)
        }
    }
    
    func loadSession(_ result: @escaping(Session) -> Void) {
        if let session = try? Store.coder.session(.init(contentsOf: Store.url.appendingPathComponent("session"))) {
            shared.load(Store.id, error: { [weak self] in
                self?.share(session)
                result(session)
            }) { [weak self] in
                let global = try! Store.coder.global(.init(contentsOf: $0))
                var update = Update(result: result)
                update.session = session
                if global.0 > update.session.counter {
                    update.session.counter = global.0
                    update.write = true
                } else if global.0 < update.session.counter {
                    update.share = true
                }
                global.1.forEach { project in
                    if let local = update.session.projects.first(where: { $0.id == project.0 }) {
                        if local.time < project.1 {
                            update.download.append(project.0)
                        } else {
                            
                        }
                    } else {
                        update.download.append(project.0)
                    }
                }
                self?.merge(update)
            }
        } else {
            shared.load(Store.id, error: { [weak self] in
                let session = Session()
                self?.write(session)
                self?.share(session)
                result(session)
            }) { [weak self] in
                let session = Session()
                session.overwrite(try! Store.coder.global(.init(contentsOf: $0)))
                self?.write(session)
                result(session)
            }
        }
    }
    
    func prepare() {
        var root = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var resources = URLResourceValues()
        resources.isExcludedFromBackup = true
        try! root.setResourceValues(resources)
        try! FileManager.default.createDirectory(at: Store.url, withIntermediateDirectories: true)
    }
    
    private func loadUbi() {
        ubi.synchronize()
        if let id = ubi.string(forKey: "id") {
            Store.id = id
        } else {
            Store.id = UUID().uuidString
            ubi.set(Store.id, forKey: "id")
            ubi.synchronize()
        }
    }
    
    private func merge(_ update: Update) {
        var update = update
        if !update.download.isEmpty {
            let download = update.download.removeFirst()
            shared.load(Store.id + ".\(download)", error: { [weak self] in
                self?.merge(update)
            }) { [weak self] in
                update.session.projects.removeAll { $0.id == download }
                var project = try! Store.coder.project(.init(contentsOf: $0))
                project.id = download
                update.session.projects.append(project)
                update.write = true
                self?.write(project)
                self?.merge(update)
            }
        } else {
            if update.write {
                write(update.session)
            }
            if update.share {
                share(update.session)
            }
            update.result(update.session)
        }
    }
    
    private func write(_ session: Session) {
        try! Store.coder.session(session).write(to: Store.url.appendingPathComponent("session"), options: .atomic)
    }
    
    private func write(_ project: Project) {
        try! Store.coder.project(project).write(to: Store.url.appendingPathComponent("\(project.id)"), options: .atomic)
    }
    
    private func share(_ session: Session) {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("session")
        try! Store.coder.global(session).write(to: url, options: .atomic)
        shared.save(Store.id, url: url)
    }
}
