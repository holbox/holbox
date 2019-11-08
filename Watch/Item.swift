import SwiftUI

struct Item: View {
    let content: String
    let mode: String.Mode
    
    var body: some View {
        HStack {
            Text(content)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(100)
                .font(mode == .plain ? .body : mode == .bold ? Font.body.bold() : .title)
                .foregroundColor(.white)
            Spacer()
        }
    }
}
