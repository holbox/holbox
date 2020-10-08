import SwiftUI

struct Back: View {
    let title: String
    
    var body: some View {
        ZStack {
            Text(title)
                .font(.footnote)
                .foregroundColor(Color("haze"))
                .padding(.init(top: 0, leading: 40, bottom: 0, trailing: 60))
                .lineLimit(2)
            HStack {
                Button(action: {
                    WKExtension.shared().rootInterfaceController!.pop()
                }) {
                    Image(systemName: "arrow.left.circle.fill")
                        .resizable()
                        .foregroundColor(Color("haze"))
                        .frame(width: 18, height: 18)
                }
                .buttonStyle(PlainButtonStyle())
                .accentColor(.clear)
                .background(Color.clear)
                .frame(width: 50, height: 50)
                Spacer()
            }
        }
    }
}
