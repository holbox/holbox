import CloudKit

class Shared {
    func load(_ id: String, error: @escaping() -> Void, success: @escaping(URL) -> Void) {
        CKContainer(identifier: "iCloud.holbox").publicCloudDatabase.fetch(withRecordID: .init(recordName: id)) {
            if $1 == nil,
                let asset = ($0?[""] as? CKAsset)?.fileURL {
                success(asset)
            } else {
                error()
            }
        }
    }
    
    func save(_ id: String, url: URL) {
        let record = CKRecord(recordType: "Record", recordID: .init(recordName: id))
        record[""] = CKAsset(fileURL: url)
        let operation = CKModifyRecordsOperation(recordsToSave: [record])
        operation.savePolicy = .allKeys
        CKContainer(identifier: "iCloud.holbox").publicCloudDatabase.add(operation)
    }
}
