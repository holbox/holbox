import CloudKit
import Network

class Shared {
    private var network = false
    private let monitor = NWPathMonitor()
    
    func prepare() {
        monitor.start(queue: .init(label: "", qos: .background, target: .global(qos: .background)))
        monitor.pathUpdateHandler = {
            self.network = $0.status == .satisfied || $0.availableInterfaces.contains { $0.type == .other }
        }
    }
    
    func load(_ ids: [String], session: Session, error: @escaping () -> Void, result: @escaping ([URL]) -> Void) {
        guard network else { return error() }
        if session.user.isEmpty {
            CKContainer(identifier: "iCloud.holbox").fetchUserRecordID {
                guard let user = $0, $1 == nil else { return error() }
                session.update(user.recordName)
                self.load(ids, user: user.recordName, error: error, result: result)
            }
        } else {
            load(ids, user: session.user, error: error, result: result)
        }
    }
    
    func save(_ ids: [String : URL], session: Session) {
        guard network else { return }
        if session.user.isEmpty {
            CKContainer(identifier: "iCloud.holbox").fetchUserRecordID {
                guard let user = $0, $1 == nil else { return }
                session.update(user.recordName)
                self.save(ids, user: user.recordName)
            }
        } else {
            save(ids, user: session.user)
        }
    }
    
    private func load(_ ids: [String], user: String, error: @escaping () -> Void, result: @escaping ([URL]) -> Void) {
        let ids = ids.map { $0 + user }
        let operation = CKFetchRecordsOperation(recordIDs: ids.map(CKRecord.ID.init(recordName:)))
        operation.configuration.timeoutIntervalForRequest = 15
        operation.configuration.timeoutIntervalForResource = 20
        operation.fetchRecordsCompletionBlock = {
            guard let records = $0, $1 == nil else { return error() }
            result(ids.map { id in (records.values.first { $0.recordID.recordName == id }!["asset"] as! CKAsset).fileURL! })
        }
        CKContainer(identifier: "iCloud.holbox").publicCloudDatabase.add(operation)
    }
    
    private func save(_ ids: [String : URL], user: String) {
        let operation = CKModifyRecordsOperation(recordsToSave: ids.compactMap {
            let record = CKRecord(recordType: "Record", recordID: .init(recordName: $0.0 + user))
            record["asset"] = CKAsset(fileURL: $0.1)
            guard let data = try? Data(contentsOf: $0.1), !data.isEmpty else { return nil }
            return record
        })
        operation.configuration.timeoutIntervalForRequest = 20
        operation.configuration.timeoutIntervalForResource = 25
        operation.savePolicy = .allKeys
        CKContainer(identifier: "iCloud.holbox").publicCloudDatabase.add(operation)
    }
}
