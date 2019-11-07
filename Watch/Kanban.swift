import SwiftUI

struct Kanban: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        ScrollView {
            VStack {
                Header()
                Columns()
                Footer()
            }
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
    }
}

private struct Header: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack {
            Title(name: model.name(model.project))
            Button(action: {
                self.model.addCard()
            }) {
                Image("card")
                .renderingMode(.original)
            }.background(Color.clear)
                .accentColor(.clear)
        }
    }
}

private struct Title: View {
    @EnvironmentObject var model: Model
    @State var name: String
    
    var body: some View {
        VStack {
            HStack {
                Back {
                    self.model.project = -1
                }
                Spacer()
            }
            TextField(.init("Project"), text: $name) {
                self.model.name(self.name)
            }.background(Color("background")
                .cornerRadius(8))
                .accentColor(.clear)
                .padding(.vertical, 25)
                .offset(y: -10)
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

private struct Item: View {
    let content: String
    let mode: String.Mode
    
    var body: some View {
        HStack {
            Text(content)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(100)
                .font(mode == .plain ? .caption : mode == .bold ? Font.body.bold() : .title)
                .foregroundColor(.white)
            Spacer()
        }
    }
}

private struct Footer: View {
    @EnvironmentObject var model: Model
    @State private var deleting = false
    
    var body: some View {
        Button(action: {
            self.deleting = true
        }) {
            Image(systemName: "trash.circle.fill")
                .resizable()
                .foregroundColor(Color("haze"))
                .frame(width: 35, height: 35)
        }.background(Color.clear)
            .accentColor(.clear)
            .padding(.vertical, 20)
            .sheet(isPresented: $deleting) {
                Delete(title: .init("Delete.title.\(self.model.mode.rawValue)")) {
                    self.model.delete()
                    self.deleting = false
                }
            }
    }
}
