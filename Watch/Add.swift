import SwiftUI

struct Add: View {
    @ObservedObject var global: Global
    var add: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                HStack {
                    Spacer()
                    
                    Image("new")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .padding(.top, 10)
                    
                    Spacer()
                }
                Text(.init("Add.title.\(global.mode.rawValue)"))
                    .font(.headline)
                Text(.init("Add.subtitle.other"))
                    .opacity(0.4)
                Text("\(global.session.available)")
                    .font(.largeTitle)
                    .foregroundColor(Color("haze"))
                if global.session.available > 0 {
                    HStack {
                        Spacer()
                        Button(action: add) {
                            Text(.init("Add.title.\(self.global.mode.rawValue)"))
                                .foregroundColor(.black)
                                .fontWeight(.bold)
                        }.background(Color("haze")
                            .cornerRadius(6))
                            .accentColor(.clear)
                            .frame(minWidth: 120)
                        Spacer()
                    }
                } else {
                    Text(.init("Add.other"))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(10)
                }
            }
        }
    }
}
