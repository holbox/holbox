import SwiftUI

struct Back: View {
    let title: String
    
    var body: some View {
        ZStack {
            Text("sdasdasdaasasd asd asd asdas")
                .font(.caption)
                .foregroundColor(Color("haze"))
                .padding(.init(top: 0, leading: 40, bottom: 0, trailing: 60))
                .lineLimit(2)
            HStack {
                Button(action: {
                    WKExtension.shared().rootInterfaceController!.pop()
                }) {
                    Icon(name: "arrow.left.circle.fill", width: 18, height: 18, color: "haze")
                }.accentColor(.clear)
                    .background(Color.clear)
                    .frame(width: 50, height: 50)
                Spacer()
            }
        }
    }
}
