import SwiftUI

struct Add: View {
    @EnvironmentObject var model: Model
    @Binding var create: Bool
    
    var body: some View {
        ScrollView {
            if model.mode != .off {
                VStack(spacing: 10) {
                    Header()
                    Available()
                    if model.available > 0 {
                        Button(action: {
                            self.model.addProject()
                            self.create = false
                        }) {
                            Text(.init("Add.title.\(model.mode.rawValue)"))
                                .font(Font.subheadline
                                    .bold())
                                .foregroundColor(.black)
                        }.background(Color("haze")
                            .cornerRadius(12))
                            .accentColor(.clear)
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
