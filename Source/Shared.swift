import CloudKit

class Shared {
    func load(_ id: String, error: @escaping() -> Void, success: @escaping(URL) -> Void) {
        CKContainer(identifier: "iCloud.holbox").publicCloudDatabase.fetch(withRecordID: .init(recordName: id)) {
            if $1 == nil,
                let asset = ($0?["asset"] as? CKAsset)?.fileURL {
                success(asset)
            } else {
                error()
            }
        }
    }
    
    func save(_ id: String, url: URL, done: @escaping() -> Void) {
        let record = CKRecord(recordType: "Record", recordID: .init(recordName: id))
        record["asset"] = CKAsset(fileURL: url)
        let operation = CKModifyRecordsOperation(recordsToSave: [record])
        operation.savePolicy = .allKeys
        operation.perRecordCompletionBlock = { _, _ in done() }
        CKContainer(identifier: "iCloud.holbox").publicCloudDatabase.add(operation)
    }
}
