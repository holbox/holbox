import SwiftUI

struct Kanban: View {
    var body: some View {
        Circle()
    }
}

/*
struct Kanban: View {
    var body: some View {
        ScrollView {
            Header(name: $name) {
                self.model.project = -1
            }
            Button(action: {
                withAnimation(.linear(duration: 0.5)) {
                    self.model.addCard()
                }
            }) {
                Image("card")
                .renderingMode(.original)
            }.background(Color.clear)
                .accentColor(.clear)
            Columns()
            Footer(name: $name, title: .init("Delete.title.\(model.mode.rawValue)"), placeholder: .init("Project"), delete: {
                self.model.delete()
            }) {
                self.model.name(self.name)
            }
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
            .onAppear {
                self.name = self.model.name(self.model.project)
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
        ForEach(0 ..< model.cards(list), id: \.self) { index in
            NavigationLink(destination:
                Card(card: .init(list: self.list, index: index))
                    .environmentObject(self.model), tag: .init(list: self.list, index: index), selection: .init(self.$model.card)) {
                    HStack {
                        Items(card: .init(list: self.list, index: index))
                        Spacer()
                    }
            }.background(Color.clear)
                .accentColor(.clear)
        }
    }
}

private struct Items: View {
    @EnvironmentObject var model: Model
    let card: Index
    
    var body: some View {
        VStack {
            if model.content(card).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Image("empty")
                    .renderingMode(.original)
            } else {
                ForEach(model.marks(card), id: \.1) {
                    Item(content: $0.0, mode: $0.1)
                }
            }
        }
    }
}
*/
