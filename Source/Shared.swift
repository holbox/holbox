import CloudKit

class Shared {
    func load(_ ids: [String], session: Session, error: @escaping () -> Void, result: @escaping ([URL]) -> Void) {
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
        operation.configuration.timeoutIntervalForResource = 10
        operation.configuration.timeoutIntervalForRequest = 10
        operation.fetchRecordsCompletionBlock = {
            guard let records = $0, $1 == nil else { return error() }
            result(ids.map { id in (records.values.first { $0.recordID.recordName == id }!["asset"] as! CKAsset).fileURL! })
        }
        CKContainer(identifier: "iCloud.holbox").publicCloudDatabase.add(operation)
    }
    
    private func save(_ ids: [String : URL], user: String) {
        let operation = CKModifyRecordsOperation(recordsToSave: ids.map {
            let record = CKRecord(recordType: "Record", recordID: .init(recordName: $0.0 + user))
            record["asset"] = CKAsset(fileURL: $0.1)
            return record
        })
        operation.configuration.timeoutIntervalForRequest = 15
        operation.configuration.timeoutIntervalForResource = 15
        operation.savePolicy = .allKeys
        CKContainer(identifier: "iCloud.holbox").publicCloudDatabase.add(operation)
    }
}
