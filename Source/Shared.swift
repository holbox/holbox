import CloudKit

class Shared {
    func load(_ ids: [String], error: @escaping () -> Void, result: @escaping ([URL]) -> Void) {
        CKContainer(identifier: "iCloud.holbox").fetchUserRecordID {
            guard let user = $0, $1 == nil else { return error() }
            let ids = ids.map { $0 + user.recordName }
            let operation = CKFetchRecordsOperation(recordIDs: ids.map(CKRecord.ID.init(recordName:)))
            operation.configuration.timeoutIntervalForResource = 6
            operation.fetchRecordsCompletionBlock = {
                guard let records = $0, $1 == nil else { return error() }
                result(ids.map { id in (records.values.first { $0.recordID.recordName == id }!["asset"] as! CKAsset).fileURL! })
            }
            CKContainer(identifier: "iCloud.holbox").publicCloudDatabase.add(operation)
        }
    }
    
    func save(_ ids: [String : URL]) {
        CKContainer(identifier: "iCloud.holbox").fetchUserRecordID {
            guard let user = $0, $1 == nil else { return }
            let operation = CKModifyRecordsOperation(recordsToSave: ids.map {
                let record = CKRecord(recordType: "Record", recordID: .init(recordName: $0.0 + user.recordName))
                record["asset"] = CKAsset(fileURL: $0.1)
                return record
            })
            operation.configuration.timeoutIntervalForResource = 15
            operation.savePolicy = .allKeys
            CKContainer(identifier: "iCloud.holbox").publicCloudDatabase.add(operation)
        }
    }
}
