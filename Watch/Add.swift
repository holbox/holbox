import SwiftUI

struct Add: View {
    @EnvironmentObject var model: Model
    @Binding var create: Bool
    
    var body: some View {
        ScrollView {
            Title()
            Available()
            if model.available > 0 {
                Button(.init("Add.title.\(model.mode.rawValue)")) {
                    self.model.addProject()
                    self.create = false
                }.background(Color("haze")
                    .cornerRadius(12))
                    .accentColor(.clear)
                    .font(Font.subheadline
                        .bold())
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
            } else {
                Text(.init("Add.other"))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(10)
                    .opacity(0.6)
            }
        }
    }
}

private struct Title: View {
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
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack {
            Text(.init("Add.title.\(model.mode.rawValue)"))
                .font(.headline)
            Text(.init("Add.subtitle.other"))
                .opacity(0.4)
            Text("\(model.available)")
                .font(.largeTitle)
                .foregroundColor(Color("haze"))
        }
    }
}
