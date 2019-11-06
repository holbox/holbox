import SwiftUI

struct Kanban: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        ScrollView {
            Header()
            Columns()
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
    }
}

private struct Header: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack {
            Title()
            NavigationLink(destination: Circle(), isActive: $model.create) {
                Image("card")
                    .renderingMode(.original)
            }.background(Color.clear)
                .accentColor(.clear)
        }
    }
}

private struct Title: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        HStack {
            Back {
                self.model.project = -1
            }
            if model.mode != .off {
                Text(model.name(model.project))
                    .font(.caption)
                    .foregroundColor(Color("haze"))
                    .offset(x: -15)
            }
            Spacer()
        }
    }
}

private struct Columns: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        ForEach(0 ..< model.lists, id: \.self) { list in
            VStack {
                HStack {
                    Text(self.model.list(list))
                        .font(Font.caption
                            .bold())
                        .foregroundColor(Color("haze"))
                        .opacity(0.6)
                    Spacer()
                }
                Column(list: list)
            }
        }
    }
}

private struct Column: View {
    @EnvironmentObject var model: Model
    let list: Int
    
    var body: some View {
        ForEach(0 ..< model.cards(list), id: \.self) { card in
            NavigationLink(destination:
                Circle(), tag: card, selection: .init(self.$model.card)) {
                    HStack {
                        Circle()
                            .foregroundColor(.init("haze"))
                            .frame(width: 10, height: 10)
                        Text(self.model.content(self.list, card: card))
                            .foregroundColor(.init("haze"))
                            .bold()
                        Spacer()
                    }
            }.background(Color.clear)
                .accentColor(.clear)
        }
    }
}
