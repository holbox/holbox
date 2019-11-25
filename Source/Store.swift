import Foundation

class Store {
    #if DEBUG
        static let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("debug")
    #else
        static let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("holbox")
    #endif
    var shared = Shared()
    var time = TimeInterval(1.5)
    private var timer: DispatchSourceTimer?
    private static var balancing = [String: URL]()
    private static let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    private static let coder = Coder()
    
    func load(_ session: Session, result: @escaping () -> Void) {
        Store.queue.async {
            self.prepare()
            self.load(session: session) {
                DispatchQueue.main.async {
                    result()
                }
            }
        }
    }
    
    func save(_ session: Session) {
        Store.queue.async {
            self.write(session)
        }
    }
    
    func save(_ session: Session, id: Int, project: Project) {
        Store.queue.async {
            self.write(session)
            self.write(id, project: project)
            self.save(["session": self.url(session), "\(id)": Store.url.appendingPathComponent("\(id)")])
        }
    }
    
    func load(session: Session, result: @escaping () -> Void) {
        do {
            try Store.coder.session(session, data: .init(contentsOf: Store.url.appendingPathComponent("session")))
            shared.load(["session"], error: {
                var update = Update(session, result: result)
                session.items = session.items.keys.reduce(into: [:]) {
                    update.upload.append($1)
                    $0[$1] = try! Store.coder.project(.init(contentsOf: Store.url.appendingPathComponent("\($1)")))
                }
                update.share = true
                self.merge(update)
            }) {
                let global = try! Store.coder.global(.init(contentsOf: $0.first!))
                var update = Update(session, result: result)
                update.session.items = session.items.reduce(into: [:]) { map, stub in
                    if let shared = global.first(where: { $0.0 == stub.0 }) {
                        if shared.1 < stub.1.time {
                            update.upload.append(stub.0)
                        }
                    } else {
                        update.upload.append(stub.0)
                    }
                    map[stub.0] = try! Store.coder.project(.init(contentsOf: Store.url.appendingPathComponent("\(stub.0)")))
                }
                global.forEach {
                    if let local = session.items[$0.0] {
                        if local.time < $0.1 {
                            update.download.append($0.0)
                        }
                    } else {
                        update.download.append($0.0)
                    }
                }
                self.merge(update)
            }
        } catch {
            shared.load(["session"], error: {
                self.write(session)
                self.save(["session": self.url(session)])
                result()
            }) {
                let global = try! Store.coder.global(.init(contentsOf: $0.first!))
                var update = Update(session, result: result)
                update.write = true
                update.download = global.map { $0.0 }
                self.merge(update)
            }
        }
    }
    
    func refresh(_ session: Session, done: @escaping ([Int]) -> Void) {
        Store.queue.async {
            self.shared.load(["session"], error: {
                DispatchQueue.main.async { done([]) }
            }) {
                let download = try! Store.coder.global(.init(contentsOf: $0.first!)).filter {
                    session.items[$0.0] == nil || session.items[$0.0]!.time < $0.1
                }.map { $0.0 }
                if download.isEmpty {
                    DispatchQueue.main.async { done([]) }
                } else {
                    self.shared.load(download.map(String.init(_:)), error: {
                        DispatchQueue.main.async { done([]) }
                    }) { urls in
                        download.enumerated().forEach {
                            let project = try! Store.coder.project(.init(contentsOf: urls[$0.0]))
                            session.items[$0.1] = project
                            self.write($0.1, project: project)
                            self.write(session)
                        }
                        DispatchQueue.main.async { done(download) }
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
    
    func save(_ ids: [String : URL]) {
        timer?.schedule(deadline: .distantFuture)
        Store.balancing.merge(ids) { $1 }
        if timer == nil {
            timer = DispatchSource.makeTimerSource(queue: .global(qos: .background))
            timer!.activate()
            timer!.setEventHandler { [weak self] in
                guard let self = self else { return }
                self.timer!.schedule(deadline: .distantFuture)
                let balancing = Store.balancing
                Store.balancing = [:]
                self.shared.save(balancing)
            }
        }
        timer!.schedule(deadline: .now() + time)
    }
    
    private func merge(_ update: Update) {
        var update = update
        if !update.download.isEmpty {
            shared.load(update.download.map(String.init(_:)), error: {
                update.download = []
                self.merge(update)
            }) { urls in
                update.download.enumerated().forEach {
                    let project = try! Store.coder.project(.init(contentsOf: urls[$0.0]))
                    update.session.items[$0.1] = project
                    self.write($0.1, project: project)
                }
                update.download = []
                update.write = true
                self.merge(update)
            }
        } else if !update.upload.isEmpty {
            save(update.upload.reduce(into: [:]) { $0["\($1)"] = Store.url.appendingPathComponent("\($1)") })
            update.share = true
            update.upload = []
            self.merge(update)
        } else if update.share {
            save(["session": url(update.session)])
            update.share = false
            self.merge(update)
        } else {
            if update.write {
                write(update.session)
            }
            update.result()
        }
    }
    
    private func write(_ session: Session) {
        try! Store.coder.session(session).write(to: Store.url.appendingPathComponent("session"), options: .atomic)
    }
    
    private func write(_ id: Int, project: Project) {
        try! Store.coder.project(project).write(to: Store.url.appendingPathComponent("\(id)"), options: .atomic)
    }
    
    private func url(_ session: Session) -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("session")
        try! Store.coder.global(session).write(to: url, options: .atomic)
        return url
    }
}
