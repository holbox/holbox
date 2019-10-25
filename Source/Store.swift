import Foundation

class Store {
    static let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Store")
    var shared = Shared()
    private static let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    private static let coder = Coder()
    
    func load(_ result: @escaping (Session) -> Void) {
        Store.queue.async {
            self.prepare()
            self.loadSession { session in
                DispatchQueue.main.async {
                    result(session)
                }
            }
        }
    }
    
    func save(_ session: Session) {
        Store.queue.async {
            self.write(session)
        }
    }
    
    func save(_ session: Session, project: Project) {
        Store.queue.async {
            self.write(session)
            self.write(project)
            self.shared.save(["session": self.url(session), "\(project.id)": Store.url.appendingPathComponent("\(project.id)")])
        }
    }
    
    func loadSession(_ result: @escaping (Session) -> Void) {
        if let session = try? Store.coder.session(.init(contentsOf: Store.url.appendingPathComponent("session"))) {
            shared.load(["session"], error: {
                var update = Update(result: result)
                session.projects = session.projects.map {
                    var project = try! Store.coder.project(.init(contentsOf: Store.url.appendingPathComponent("\($0.id)")))
                    project.id = $0.id
                    update.upload.append($0.id)
                    return project
                }
                update.session = session
                update.share = true
                self.merge(update)
            }) {
                let global = try! Store.coder.global(.init(contentsOf: $0.first!))
                var update = Update(result: result)
                update.session = session
                update.session.projects = session.projects.map { stub in
                    var project = try! Store.coder.project(.init(contentsOf: Store.url.appendingPathComponent("\(stub.id)")))
                    project.id = stub.id
                    if let shared = global.first(where: { $0.0 == stub.id }) {
                        if shared.1 < stub.time {
                            update.upload.append(stub.id)
                        }
                    } else {
                        update.upload.append(stub.id)
                    }
                    return project
                }
                global.forEach { project in
                    if let local = session.projects.first(where: { $0.id == project.0 }) {
                        if local.time < project.1 {
                            update.download.append(project.0)
                        }
                    } else {
                        update.download.append(project.0)
                    }
                }
                self.merge(update)
            }
        } else {
            shared.load(["session"], error: {
                let session = Session()
                self.write(session)
                self.shared.save(["session": self.url(session)])
                result(session)
            }) {
                let global = try! Store.coder.global(.init(contentsOf: $0.first!))
                var update = Update(result: result)
                update.write = true
                update.download = global.map { $0.0 }
                self.merge(update)
            }
        }
    }
    
    func refresh(_ session: Session, done: @escaping () -> Void) {
        Store.queue.async {
            self.shared.load(["session"], error: {
                DispatchQueue.main.async { done() }
            }) {
                let download = try! Store.coder.global(.init(contentsOf: $0.first!)).filter { project in
                    if let local = session.projects.first(where: { $0.id == project.0 }), local.time > project.1 {
                        return false
                    }
                    return true
                }.map { $0.0 }
                if download.isEmpty {
                    DispatchQueue.main.async { done() }
                } else {
                    self.shared.load(download.map(String.init(_:)), error: {
                        DispatchQueue.main.async { done() }
                    }) { urls in
                        download.enumerated().forEach {
                            var project = try! Store.coder.project(.init(contentsOf: urls[$0.0]))
                            project.id = $0.1
                            session.projects.removeAll { $0.id == project.id }
                            session.projects.append(project)
                            self.write(project)
                            self.write(session)
                        }
                        DispatchQueue.main.async { done() }
                    }
                }
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
    
    private func merge(_ update: Update) {
        var update = update
        if !update.download.isEmpty {
            shared.load(update.download.map(String.init(_:)), error: {
                update.download = []
                self.merge(update)
            }) { urls in
                update.download.enumerated().forEach {
                    var project = try! Store.coder.project(.init(contentsOf: urls[$0.0]))
                    project.id = $0.1
                    update.session.projects.removeAll { $0.id == project.id }
                    update.session.projects.append(project)
                    self.write(project)
                }
                update.download = []
                update.write = true
                self.merge(update)
            }
        } else if !update.upload.isEmpty {
            shared.save(update.upload.reduce(into: [:]) { $0["\($1)"] = Store.url.appendingPathComponent("\($1)") })
            update.share = true
            update.upload = []
            self.merge(update)
        } else if update.share {
            shared.save(["session": url(update.session)])
            update.share = false
            self.merge(update)
        } else {
            if update.write {
                write(update.session)
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
    
    private func url(_ session: Session) -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("session")
        try! Store.coder.global(session).write(to: url, options: .atomic)
        return url
    }
}
