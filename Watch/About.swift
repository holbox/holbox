import SwiftUI

struct About: View {
    var body: some View {
        ScrollView {
            VStack {
                HStack {
//                    Back()
                    Spacer()
                }
                Title()
                HStack {
                    Text(.init("Privacy.title"))
                        .font(.headline)
                        .foregroundColor(Color("haze"))
                        .opacity(0.6)
                    Spacer()
                }
                Text(.init("Privacy.label"))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(50)
                    .offset(.init(width: 0, height: -25))
            }
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
    }
}

private struct Title: View {
    var body: some View {
        HStack {
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 70, height: 70)
            VStack(alignment: .leading) {
                Spacer()
                Text(.init("About.small"))
                    .font(Font.body.bold())
                Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)
                Spacer()
            }
        }.offset(y: -10)
    }
}
