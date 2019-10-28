import SwiftUI

struct Board: View {
    @EnvironmentObject var global: Global
    
    var body: some View {
        List {
            if global.project != nil {
                Header(name: self.global.session.name(self.global.project!))
                ForEach(0 ..< global.session.lists(global.project!), id: \.self) {
                    Column(index: $0)
                }
            }
        }
    }
}

private struct Header: View {
    @EnvironmentObject var global: Global
    @State var name: String
    
    var body: some View {
        Section(header:
            TextField(.init("Kanban.project"), text: $name) {
                self.global.session.name(self.global.project!, name: self.name)
            }.background(Color("background")
                .cornerRadius(6))
                .font(Font.body.bold())
        ) {
            Button(action: {
                self.global.session.add(self.global.project!, list: 0)
                self.global.session = self.global.session
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.global.card = nil
                    self.global.card = 0
                }
            }) {
                HStack {
                    Spacer()
                    Image("card")
                    Spacer()
                }
            }.listRowBackground(Color.clear)
        }
    }
}

private struct Column: View {
    @EnvironmentObject var global: Global
    let index: Int
    
    var body: some View {
        Section(header:
                                Text(self.global.session.name(self.global.project!, list: index))
                                    .font(Font.headline.bold())
                                    .foregroundColor(Color("haze")
                                        .opacity(0.6))) {
                                    ForEach(0 ..< self.global.session.cards(self.global.project!, list: index), id: \.self) { card in
                                        NavigationLink(destination: Card(position: .init(self.index, card))
                                            .onDisappear(perform: {
        //                                    self.global.card = nil
        //                                    self.global.session.content(self.global.project!, list: self.list, card: self.card, content: self.content)
                                        }), tag: card, selection: self.$global.card) {
                                            if self.global.session.content(self.global.project!, list: self.index, card: card).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                Image("empty")
                                            } else {
                                                Text(self.global.session.content(self.global.project!, list: self.index, card: card))
                                                    .fixedSize(horizontal: false, vertical: true)
                                                    .lineLimit(15)
                                                    .padding(.vertical, 8)
                                            }
                                        }.listRowBackground(Color.clear)
                                    }.onDelete {
                                        self.global.session.delete(self.global.project!, list: self.index, card: $0.first!)
                                        self.global.session = self.global.session
                                    }
                                    if self.global.session.cards(self.global.project!, list: index) == 0 {
                                        Spacer()
                                            .listRowBackground(Color.clear)
                                    }
                            }
    }
}
