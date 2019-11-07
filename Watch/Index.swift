import Foundation

struct Index: Hashable {
    static let null = Index(list: -1, index: -1)
    
    let list: Int
    let index: Int
}
