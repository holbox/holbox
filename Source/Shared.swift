import CloudKit

class Shared {
    func load(_ ids: [String], result: @escaping ([String : URL]) -> Void) {
        let operation = CKFetchRecordsOperation(recordIDs: ids.map(CKRecord.ID.init(recordName:)))
        operation.configuration.timeoutIntervalForResource = 10
        operation.fetchRecordsCompletionBlock = {
            guard $0 != nil && $1 == nil else { return result([:]) }
            result($0!.reduce(into: [:]) { $0[$1.0.recordName] = ($1.1["asset"] as! CKAsset).fileURL! })
        }
        CKContainer(identifier: "iCloud.holbox").publicCloudDatabase.add(operation)
    }
    
    func save(_ id: String, url: URL, done: @escaping () -> Void) {
        let record = CKRecord(recordType: "Record", recordID: .init(recordName: id))
        record["asset"] = CKAsset(fileURL: url)
        let operation = CKModifyRecordsOperation(recordsToSave: [record])
        operation.configuration.timeoutIntervalForResource = 10
        operation.savePolicy = .allKeys
        operation.completionBlock = done
        CKContainer(identifier: "iCloud.holbox").publicCloudDatabase.add(operation)
    }
}
