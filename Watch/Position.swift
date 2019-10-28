import Foundation

final class Position: ObservableObject {
    @Published var column: Int
    @Published var card: Int
    
    init(_ column: Int, _ card: Int) {
        self.column = column
        self.card = card
    }
}
