import CloudKit

class Shared {
    func load(_ result: @escaping (String) -> Void) {
        CKop
        let operation = CKFetchRecordsOperation(recordIDs: [.init(recordName: "credential")])
        operation.configuration.timeoutIntervalForResource = 10
        operation.fetchRecordsCompletionBlock = {
            guard $0 != nil && $1 == nil else {
                let id = UUID().uuidString
                self.refresh(id)
                result(id)
                return
            }
            print("loaded: \($0!.first!.1["id"]!)")
            result($0!.first!.1["id"]!)
        }
        CKContainer(identifier: "iCloud.holbox").privateCloudDatabase.add(operation)
    }
    
    func load(_ ids: [String], result: @escaping ([String : URL]) -> Void) {
        let operation = CKFetchRecordsOperation(recordIDs: ids.map(CKRecord.ID.init(recordName:)))
        operation.configuration.timeoutIntervalForResource = 15
        operation.fetchRecordsCompletionBlock = {
            guard $0 != nil && $1 == nil else { return result([:]) }
            result($0!.reduce(into: [:]) { $0[$1.0.recordName] = ($1.1["asset"] as! CKAsset).fileURL! })
        }
        CKContainer(identifier: "iCloud.holbox").publicCloudDatabase.add(operation)
    }
    
    func save(_ ids: [String : URL], done: @escaping () -> Void) {
        let operation = CKModifyRecordsOperation(recordsToSave: ids.map {
            let record = CKRecord(recordType: "Record", recordID: .init(recordName: $0.0))
            record["asset"] = CKAsset(fileURL: $0.1)
            return record
        })
        operation.configuration.timeoutIntervalForResource = 15
        operation.savePolicy = .allKeys
        operation.completionBlock = done
        CKContainer(identifier: "iCloud.holbox").publicCloudDatabase.add(operation)
    }
    
    func refresh(_ id: String) {
        let record = CKRecord(recordType: "Credential", recordID: .init(recordName: "credential"))
        record["id"] = id
        let operation = CKModifyRecordsOperation(recordsToSave: [record])
        operation.configuration.timeoutIntervalForResource = 15
        operation.savePolicy = .allKeys
        operation.perRecordCompletionBlock = {
            print("record: \($0)")
            print("error: \($1)")
        }
        operation.completionBlock = {
            print("saved")
        }
        CKContainer(identifier: "iCloud.holbox").privateCloudDatabase.add(operation)
    }
}
