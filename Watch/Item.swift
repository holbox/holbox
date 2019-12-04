import SwiftUI

struct Item: View {
    let string: String
    
    var body: some View {
        ForEach(marks(), id: \.1) { mark in
            HStack {
                Marked(mark: mark)
                Spacer()
            }
        }
    }
    
    private func marks() -> [(String, String.Mode)] {
        return string.mark { ({
            $0.first == "\n" ? .init($0.dropFirst()) : .init($0)
        } (string[$1]), $0) }
    }
}

private struct Marked: View {
    let mark: (String, String.Mode)
    
    var body: some View {
        Text(mark.0)
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(100)
            .font(mark.1 == .emoji ? .title : mark.1 == .bold ? Font.caption.bold() : .caption)
            .foregroundColor(mark.1 == .plain ? .white : Color("haze"))
    }
}
