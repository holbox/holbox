import CloudKit

class Shared {
    func load(_ ids: [String], error: @escaping () -> Void, result: @escaping ([URL]) -> Void) {
        let operation = CKFetchRecordsOperation(recordIDs: ids.map(CKRecord.ID.init(recordName:)))
        operation.configuration.timeoutIntervalForResource = 25
        operation.fetchRecordsCompletionBlock = {
            guard let records = $0, $1 == nil else { return error() }
            result(ids.map { id in (records.values.first { $0.recordID.recordName == id }!["asset"] as! CKAsset).fileURL! })
        }
        CKContainer(identifier: "iCloud.holbox").privateCloudDatabase.add(operation)
    }
    
    func save(_ ids: [String : URL]) {
        let operation = CKModifyRecordsOperation(recordsToSave: ids.map {
            let record = CKRecord(recordType: "Record", recordID: .init(recordName: $0.0))
            record["asset"] = CKAsset(fileURL: $0.1)
            return record
        })
        operation.configuration.timeoutIntervalForResource = 40
        operation.savePolicy = .allKeys
        CKContainer(identifier: "iCloud.holbox").privateCloudDatabase.add(operation)
    }
}
