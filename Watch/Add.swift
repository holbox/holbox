import SwiftUI

struct Add: View {
    @EnvironmentObject var global: Global
    var add: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Header()
                Available()
                if true || global.session.available > 0 {
                    Create(add: add)
                } else {
                    Text(.init("Add.other"))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(10)
                }
            }
        }
    }
}

private struct Header: View {
    var body: some View {
        HStack {
            Spacer()
            Image("new")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .padding(.top, 10)
            Spacer()
        }
    }
}

private struct Available: View {
    @EnvironmentObject var global: Global
    
    var body: some View {
        VStack {
            Text(.init("Add.title.\(global.mode.rawValue)"))
                .font(.headline)
            Text(.init("Add.subtitle.other"))
                .opacity(0.4)
            Text("\(global.session.available)")
                .font(.largeTitle)
                .foregroundColor(Color("haze"))
        }
    }
}

private struct Create: View {
    @EnvironmentObject var global: Global
    var add: () -> Void
    
    var body: some View {
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
    }
}
