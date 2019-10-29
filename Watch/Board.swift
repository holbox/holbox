import SwiftUI

struct Board: View {
    @EnvironmentObject var session: Session
    
    var body: some View {
        List {
            Header(name: session.name)
            ForEach(0 ..< session.columns, id: \.self) {
                Column(column: $0)
            }
        }
    }
}
private struct Header: View {
    @EnvironmentObject var session: Session
    @State var name: String
    
    var body: some View {
        Section(header:
            VStack {
                Back {
                    self.session.project = nil
                }
                TextField(.init("Kanban.project"), text: $name) {
                    self.session.name(self.name)
                }.background(Color.clear)
                    .accentColor(.clear)
                    .font(Font.body.bold())
            }
        ) {
            Create()
        }
    }
}

private struct Create: View {
    @EnvironmentObject var session: Session
    
    var body: some View {
        Button(action: {
            self.session.card()
        }) {
            HStack {
                Spacer()
                Image("card")
                Spacer()
            }
        }.listRowBackground(Color.clear)
    }
}

private struct Column: View {
    @EnvironmentObject var session: Session
    let column: Int
    
    var body: some View {
        Section(header:
            Text(session.list(column))
                .font(Font.headline.bold())
                .foregroundColor(Color("haze")
                    .opacity(0.6))) {
                        ForEach(0 ..< self.session.cards(column), id: \.self) {
                            Item(column: self.column, card: $0)
                        }.onDelete {
                            self.session.delete(self.column, card: $0)
                        }
                        if self.session.cards(column) == 0 {
                            Spacer()
                                .listRowBackground(Color.clear)
                        }
        }
    }
}

private struct Item: View {
    @EnvironmentObject var session: Session
    let column: Int
    let card: Int
    
    var body: some View {
        Button(action: {
            self.session.item = (self.column, self.card)
        }) {
            if session.content(column, card: card).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Image("empty")
            } else {
                Text(session.content(column, card: card))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(15)
                    .padding(.vertical, 8)
            }
        }.listRowBackground(Color.clear)
    }
}
