import Foundation

class Store {
    static private(set) var id = ""
    var ubi = NSUbiquitousKeyValueStore.default
    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Store")
    private let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    
    func load(_ result: @escaping(Session) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.loadId()
        }
    }
    
    func save(_ session: Session) {
        
    }
    
    func save(_ project: Project) {
        
    }
    
    func prepare() {
        var root = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var resources = URLResourceValues()
        resources.isExcludedFromBackup = true
        try! root.setResourceValues(resources)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    func loadId() {
        prepare()
        if let id = try? String(decoding: Data(contentsOf: url.appendingPathComponent("id")), as: UTF8.self) {
            Store.id = id
        } else {
            loadUbi()
            try! Data(Store.id.utf8).write(to: url.appendingPathComponent("id"), options: .atomic)
        }
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
}
