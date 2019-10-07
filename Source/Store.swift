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
            }) { _ in
                
            }
        } else {
            shared.load(Store.id, error: { [weak self] in
                let session = Session()
                try! Store.coder.code(session).write(to: Store.url.appendingPathComponent("session"), options: .atomic)
                self?.share(session)
                result(session)
            }) { _ in
//                let session = Session()
//                session.global = try! Store.coder.global(.init(contentsOf: $0))
//                try! Store.coder.code(session).write(to: Store.url.appendingPathComponent("session"), options: .atomic)
//                result(session)
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
    
    private func share(_ session: Session) {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("session")
        try! Store.coder.code(session.global).write(to: url, options: .atomic)
        shared.save(Store.id, url: url)
    }
}
