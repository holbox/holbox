import Foundation

class Store {
#if DEBUG
    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("debug")
#else
    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("holbox")
#endif
    var shared = Shared()
    var time = TimeInterval(1)
    private var timer: DispatchSourceTimer?
    private var balancing = [String : URL]()
    private let queue = DispatchQueue(label: "", qos: .utility)
    private let coder = Coder()
    
    func load(_ session: Session, completion: @escaping () -> Void) {
        queue.async {
            self.prepare()
            self.shared.prepare()
            self.load(session: session) {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    func save(_ session: Session) {
        queue.async {
            self.write(session)
        }
    }
    
    func save(_ session: Session, id: Int, project: Project) {
        queue.async {
            self.write(session)
            self.write(id, project: project)
            self.save(["session": self.url(session), "\(id)": self.url.appendingPathComponent("\(id)")], session: session)
        }
    }
    
    func load(session: Session, result: @escaping () -> Void) {
        do {
            try coder.session(session, data: .init(contentsOf: url.appendingPathComponent("session.holbox")))
            shared.load(["session"], session: session, error: {
                var update = Update(session, result: result)
                session.items = session.items.keys.reduce(into: [:]) {
                    update.upload.append($1)
                    $0[$1] = try! self.coder.project(.init(contentsOf: self.url.appendingPathComponent("\($1)")))
                }
                update.share = true
                self.merge(update, session: session)
            }) {
                let global = try! self.coder.global(.init(contentsOf: $0.first!))
                var update = Update(session, result: result)
                update.session.items = session.items.reduce(into: [:]) { map, stub in
                    if let shared = global.first(where: { $0.0 == stub.0 }) {
                        if shared.1 < stub.1.time {
                            update.upload.append(stub.0)
                        }
                    } else {
                        update.upload.append(stub.0)
                    }
                    map[stub.0] = try! self.coder.project(.init(contentsOf: self.url.appendingPathComponent("\(stub.0)")))
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
                self.merge(update, session: session)
            }
        } catch {
            shared.load(["session"], session: session, error: {
                self.write(session)
                self.save(["session": self.url(session)], session: session)
                result()
            }) {
                let global = try! self.coder.global(.init(contentsOf: $0.first!))
                var update = Update(session, result: result)
                update.write = true
                update.download = global.map(\.0)
                self.merge(update, session: session)
            }
        }
    }
    
    func refresh(_ session: Session, done: @escaping ([Int]) -> Void) {
        queue.async {
            self.shared.load(["session"], session: session, error: {
                DispatchQueue.main.async { done([]) }
            }) {
                let download = try! self.coder.global(.init(contentsOf: $0.first!)).filter {
                    session.items[$0.0] == nil || session.items[$0.0]!.time < $0.1
                }.map { $0.0 }
                if download.isEmpty {
                    DispatchQueue.main.async { done([]) }
                } else {
                    self.shared.load(download.map(String.init(_:)), session: session, error: {
                        DispatchQueue.main.async { done([]) }
                    }) { urls in
                        download.enumerated().forEach {
                            let project = try! self.coder.project(.init(contentsOf: urls[$0.0]))
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
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    func save(_ ids: [String : URL], session: Session) {
        timer?.schedule(deadline: .distantFuture)
        balancing.merge(ids) { $1 }
        if timer == nil {
            timer = DispatchSource.makeTimerSource(queue: .global(qos: .background))
            timer!.activate()
            timer!.setEventHandler {
                self.timer!.schedule(deadline: .distantFuture)
                let balancing = self.balancing
                self.balancing = [:]
                self.shared.save(balancing, session: session)
            }
        }
        timer!.schedule(deadline: .now() + time)
    }
    
    private func merge(_ update: Update, session: Session) {
        var update = update
        if !update.download.isEmpty {
            shared.load(update.download.map(String.init(_:)), session: session, error: {
                update.download = []
                self.merge(update, session: session)
            }) { urls in
                update.download.enumerated().forEach {
                    let project = try! self.coder.project(.init(contentsOf: urls[$0.0]))
                    update.session.items[$0.1] = project
                    self.write($0.1, project: project)
                }
                update.download = []
                update.write = true
                self.merge(update, session: session)
            }
        } else if !update.upload.isEmpty {
            save(update.upload.reduce(into: [:]) { $0["\($1)"] = url.appendingPathComponent("\($1)") }, session: session)
            update.share = true
            update.upload = []
            self.merge(update, session: session)
        } else if update.share {
            save(["session": url(update.session)], session: session)
            update.share = false
            self.merge(update, session: session)
        } else {
            if update.write {
                write(update.session)
            }
            update.result()
        }
    }
    
    private func write(_ session: Session) {
        try! coder.session(session).write(to: url.appendingPathComponent("session.holbox"), options: .atomic)
    }
    
    private func write(_ id: Int, project: Project) {
        try! coder.project(project).write(to: url.appendingPathComponent("\(id)"), options: .atomic)
    }
    
    private func url(_ session: Session) -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("session.holbox")
        try! coder.global(session).write(to: url, options: .atomic)
        return url
    }
}
