import Foundation

class Store {
    static var id = ""
    static let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Store")
    var ubi = NSUbiquitousKeyValueStore.default
    var shared = Shared()
    private static let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    private static let coder = Coder()
    
    func load(_ result: @escaping (Session) -> Void) {
        Store.queue.async {
            self.prepare()
            self.loadId()
            self.loadSession { session in
                DispatchQueue.main.async {
                    result(session)
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
            self.shared.save(Store.id, url: url, done: done)
        }
    }
    
    func save(_ project: Project, done: @escaping () -> Void) {
        Store.queue.async {
            self.write(project)
            self.share(project.id, done: done)
        }
    }
    
    func loadId() {
        if let id = try? String(decoding: Data(contentsOf: Store.url.appendingPathComponent("id")), as: UTF8.self) {
            Store.id = id
        } else {
            loadUbi()
            try! Data(Store.id.utf8).write(to: Store.url.appendingPathComponent("id"), options: .atomic)
        }
    }
    
    func loadSession(_ result: @escaping (Session) -> Void) {
        if let session = try? Store.coder.session(.init(contentsOf: Store.url.appendingPathComponent("session"))) {
            shared.load(Store.id, error: {
                self.share(session) {
                    result(session)
                }
            }) {
                let global = try! Store.coder.global(.init(contentsOf: $0))
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
        } else {
            shared.load(Store.id, error: {
                let session = Session()
                self.share(session) {
                    self.write(session)
                    result(session)
                }
            }) {
                let global = try! Store.coder.global(.init(contentsOf: $0))
                var update = Update(result: result)
                update.session.counter = global.0
                update.write = true
                update.download = global.1.map { $0.0 }
                self.merge(update)
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
            shared.load(Store.id + "\(download)", error: {
                self.merge(update)
            }) {
                update.session.projects.removeAll { $0.id == download }
                var project = try! Store.coder.project(.init(contentsOf: $0))
                project.id = download
                update.session.projects.append(project)
                update.write = true
                self.write(project)
                self.merge(update)
            }
        } else if !update.upload.isEmpty {
            update.share = true
            let upload = update.upload.removeFirst()
            share(upload) {
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
    
    private func share(_ project: Int, done: @escaping () -> Void) {
        shared.save(Store.id + "\(project)", url: Store.url.appendingPathComponent("\(project)"), done: done)
    }
}
