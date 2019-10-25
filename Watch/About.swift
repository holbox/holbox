import SwiftUI

struct About: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                    VStack {
                        Spacer()
                        Text(.init("About.small"))
                            .font(Font.body.bold())
                        HStack {
                            Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)
                            Spacer()
                        }
                        Spacer()
                    }
                }
                HStack {
                    Text(.init("Privacy.title"))
                        .font(.title)
                    Spacer()
                }
                Text(.init("Privacy.label"))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(50)
            }
        }
    }
}
