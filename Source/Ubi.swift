import Foundation

class Ubi {
    func load(_ result: @escaping (String) -> Void) {
        if FileManager.default.ubiquityIdentityToken != nil {
            DispatchQueue.global(qos: .background).async {
                NSUbiquitousKeyValueStore.default.set(true, forKey: "loading")
                NSUbiquitousKeyValueStore.default.synchronize()
                DispatchQueue.global(qos: .background).async {
                    if let id = NSUbiquitousKeyValueStore.default.string(forKey: "id") {
                        result(id)
                    } else {
                        self.new(result)
                    }
                }
            }
        } else {
            new(result)
        }
    }
        
    private func new(_ result: @escaping (String) -> Void) {
        let id = UUID().uuidString
        NSUbiquitousKeyValueStore.default.set(id, forKey: "id")
        NSUbiquitousKeyValueStore.default.synchronize()
        result(id)
    }
}
