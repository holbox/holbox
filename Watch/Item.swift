import SwiftUI

struct Item: View {
    let content: String
    let mode: String.Mode
    
    var body: some View {
        HStack {
            Text(content)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(100)
                .font(mode == .plain ? .caption : mode == .bold ? Font.caption.bold() : .title)
                .foregroundColor(.white)
            Spacer()
        }
    }
}
