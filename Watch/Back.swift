import SwiftUI

struct Back: View {
    let action: () -> Void
    
    var body: some View {
        HStack {
            Button(action: action) {
                Icon(name: "arrow.left.circle.fill", width: 18, height: 18, color: "haze")
            }.accentColor(.clear)
                .background(Color.clear)
                .frame(width: 60, height: 60)
        }
    }
}
