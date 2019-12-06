import SwiftUI

struct Item: View {
    let string: String
    
    var body: some View {
        VStack {
            if string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Circle()
                    .foregroundColor(.init("haze"))
                    .opacity(0.5)
                    .frame(width: 20, height: 20)
            } else {
                ForEach(marks(), id: \.0) { mark in
                    HStack {
                        Marked(mark: mark)
                        Spacer()
                    }
                }
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
            .lineLimit(300)
            .font(mark.1 == .emoji ? .title : mark.1 == .bold ? Font.caption.bold() : .caption)
            .foregroundColor(mark.1 == .tag ? Color("haze") : .white)
    }
}
