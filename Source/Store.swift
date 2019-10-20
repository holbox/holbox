import Foundation

class Store {
    static var id = ""
    static let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Store")
    var ubi = Ubi()
    var shared = Shared()
    private static let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    private static let coder = Coder()
    
    func load(_ result: @escaping (Session) -> Void) {
        Store.queue.async {
            self.prepare()
            self.loadId {
                self.loadSession { session in
                    DispatchQueue.main.async {
                        result(session)
                    }
                }
            }
        }
    }
    
    func save(_ session: Session, done: @escaping () -> Void) {
        Store.queue.async {
            self.write(session)
            done()
        }
    }
    
    func share(_ session: Session, done: @escaping () -> Void) {
        Store.queue.async {
            let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("session")
            try! Store.coder.global(session).write(to: url, options: .atomic)
            self.shared.save([Store.id: url], done: done)
        }
    }
    
    func save(_ project: Project, done: @escaping () -> Void) {
        Store.queue.async {
            self.write(project)
            self.share([project.id], done: done)
        }
    }
    
    func loadId(_ done: @escaping () -> Void) {
        if let id = try? String(decoding: Data(contentsOf: Store.url.appendingPathComponent("id")), as: UTF8.self) {
            Store.id = id
            done()
        } else {
            ubi.load {
                Store.id = $0
                try! Data(Store.id.utf8).write(to: Store.url.appendingPathComponent("id"), options: .atomic)
                done()
            }
        }
    }
    
    func loadSession(_ result: @escaping (Session) -> Void) {
        if let session = try? Store.coder.session(.init(contentsOf: Store.url.appendingPathComponent("session"))) {
            shared.load([Store.id]) {
                if $0[Store.id] == nil {
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
                } else {
                    let global = try! Store.coder.global(.init(contentsOf: $0[Store.id]!))
                    var update = Update(result: result)
                    update.session = session
                    if global.0 > session.counter {
                        update.session.counter = global.0
                        update.write = true
                    } else if global.0 < session.counter {
                        update.share = true
                    }
                    update.session.projects = session.projects.map { stub in
                        var project = try! Store.coder.project(.init(contentsOf: Store.url.appendingPathComponent("\(stub.id)")))
                        project.id = stub.id
                        if let shared = global.1.first(where: { $0.0 == stub.id }) {
                            if shared.1 < stub.time {
                                update.upload.append(stub.id)
                            }
                        } else {
                            update.upload.append(stub.id)
                        }
                        return project
                    }
                    global.1.forEach { project in
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
            }
        } else {
            shared.load([Store.id]) {
                if $0[Store.id] == nil {
                    let session = Session()
                    self.share(session) {
                        self.write(session)
                        result(session)
                    }
                } else {
                    let global = try! Store.coder.global(.init(contentsOf: $0[Store.id]!))
                    var update = Update(result: result)
                    update.session.counter = global.0
                    update.write = true
                    update.download = global.1.map { $0.0 }
                    self.merge(update)
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
            shared.load(update.download.map { Store.id + "\($0)" }) {
                $0.forEach {
                    var project = try! Store.coder.project(.init(contentsOf: $0.1))
                    project.id = Int($0.0.replacingOccurrences(of: Store.id, with: ""))!
                    update.session.projects.removeAll { $0.id == project.id }
                    update.session.projects.append(project)
                    self.write(project)
                }
                update.download = []
                update.write = true
                self.merge(update)
            }
        } else if !update.upload.isEmpty {
            update.share = true
            share(update.upload) {
                update.upload = []
                self.merge(update)
            }
        } else if update.share {
            update.share = false
            share(update.session) {
                self.merge(update)
            }
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
    
    private func share(_ projects: [Int], done: @escaping () -> Void) {
        shared.save(projects.reduce(into: [:]) { $0[Store.id + "\($1)"] = Store.url.appendingPathComponent("\($1)") }, done: done)
    }
}
