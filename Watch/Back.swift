import SwiftUI

struct Back: View {
    let action: () -> Void
    
    var body: some View {
        HStack {
            Button(action: action) {
                Image(systemName: "arrow.left.circle.fill")
                    .resizable()
                    .foregroundColor(Color("haze"))
                    .frame(width: 18, height: 18)
            }.accentColor(.clear)
                .background(Color.clear)
                .frame(width: 60, height: 60)
        }
    }
}
