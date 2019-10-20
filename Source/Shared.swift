import CloudKit

class Shared {
    func load(_ ids: [String], error: @escaping () -> Void, result: @escaping ([String : URL]) -> Void) {
        let operation = CKFetchRecordsOperation(recordIDs: ids.map(CKRecord.ID.init(recordName:)))
        operation.configuration.timeoutIntervalForResource = 15
        operation.fetchRecordsCompletionBlock = {
            guard $0 != nil && $1 == nil else { return error() }
            result($0!.reduce(into: [:]) { $0[$1.0.recordName] = ($1.1["asset"] as! CKAsset).fileURL! })
        }
        CKContainer(identifier: "iCloud.holbox").privateCloudDatabase.add(operation)
    }
    
    func save(_ ids: [String : URL]) {
        let operation = CKModifyRecordsOperation(recordsToSave: ids.map {
            let record = CKRecord(recordType: "Record", recordID: .init(recordName: $0.0))
            record["asset"] = CKAsset(fileURL: $0.1)
            return record
        })
        operation.configuration.timeoutIntervalForResource = 30
        operation.savePolicy = .allKeys
        CKContainer(identifier: "iCloud.holbox").privateCloudDatabase.add(operation)
    }
}
