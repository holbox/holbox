import Foundation

class Store {
    static private(set) var id = ""
    static let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Store")
    private static let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
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
        if let session = try? JSONDecoder().decode(Session.self, from: Data(contentsOf: Store.url.appendingPathComponent("session"))) {
            
        } else {
            loadShared {
                let session = Session()
                session.global = $0
                try! JSONEncoder().encode(session).write(to: Store.url.appendingPathComponent("session"), options: .atomic)
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
    
    private func loadShared(_ result: @escaping(Session.Global) -> Void) {
        shared.load(result) { result(.init()) }
    }
}
