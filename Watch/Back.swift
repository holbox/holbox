import SwiftUI

struct Back: View {
    var body: some View {
        HStack {
            Button(action: {
                WKExtension.shared().rootInterfaceController!.pop()
            }) {
                Icon(name: "arrow.left.circle.fill", width: 18, height: 18, color: "haze")
            }.accentColor(.clear)
                .background(Color.clear)
                .frame(width: 60, height: 60)
        }
    }
}
