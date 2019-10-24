import SwiftUI

struct Board: View {
    @ObservedObject var global: Global
    
    var body: some View {
        List {
            if global.project != nil {
                Section(header:
                    VStack {
                        Text(self.global.session.name(self.global.project!))
                            .font(.largeTitle)
                    }
                ) {
                    Button(.init("Kanban.rename")) {
                        
                    }.listRowBackground(Color("background").cornerRadius(6))
                    Button(.init("Kanban.delete")) {
                        self.global.project = nil
                    }.listRowBackground(Color("background").cornerRadius(6))
                    Button(action: {
                        
                    }) {
                        HStack {
                            Spacer()
                            Image("card")
                            Spacer()
                        }
                    }.listRowBackground(Color.clear)
                }
                ForEach(0 ..< global.session.lists(global.project!), id: \.self) { list in
                    Section(header:
                        Text(self.global.session.name(self.global.project!, list: list))
                            .font(.title)) {
                            ForEach(0 ..< self.global.session.cards(self.global.project!, list: list), id: \.self) { card in
                                NavigationLink(destination: Card(global: self.global, content: self.global.session.content(self.global.project!, list: list, card: card), list: list, card: card), tag: card, selection: self.$global.card) {
                                    if self.global.session.content(self.global.project!, list: list, card: card).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        Image("empty")
                                    } else {
                                        Text(self.global.session.content(self.global.project!, list: list, card: card))
                                    }
                                }.listRowBackground(Color.clear)
                            }
                            if self.global.session.cards(self.global.project!, list: list) == 0 {
                                Spacer()
                                    .listRowBackground(Color.clear)
                            }
                    }
                }
            }
        }
    }
}
