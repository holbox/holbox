import SwiftUI

struct Board: View {
    @EnvironmentObject var session: Session
    let project: Int
    
    var body: some View {
        List {
            Header(name: session.name(project), project: project)
            ForEach(0 ..< session.lists(project), id: \.self) {
                Column(index: $0, project: self.project)
            }
        }
    }
}
private struct Header: View {
    @EnvironmentObject var session: Session
    @State var name: String
    let project: Int
    
    var body: some View {
        Section(header:
            TextField(.init("Kanban.project"), text: $name) {
                self.session.name(self.project, name: self.name)
            }.background(Color("background")
                .cornerRadius(6))
                .font(Font.body.bold())
        ) {
            Create(project: project)
        }
    }
}

private struct Create: View {
    @EnvironmentObject var session: Session
    let project: Int
    
    var body: some View {
        Button(action: {
            self.session.add(self.project)
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
    let index: Int
    let project: Int
    
    var body: some View {
        Section(header:
            Text(session.name(project, list: index))
                .font(Font.headline.bold())
                .foregroundColor(Color("haze")
                    .opacity(0.6))) {
                        ForEach(0 ..< self.session.cards(self.project, list: index), id: \.self) {
                            Item(column: self.index, card: $0, project: self.project)
                        }.onDelete {
                            self.session.delete(self.project, list: self.index, card: $0)
                        }
                        if self.session.cards(self.project, list: index) == 0 {
                            Spacer()
                                .listRowBackground(Color.clear)
                        }
        }
    }
}

private struct Item: View {
    @EnvironmentObject var session: Session
    @State var column: Int
    @State var card: Int
    let project: Int
    
    var body: some View {
        NavigationLink(destination:
            Card(column: $column, card: $card, project: project)
                .environmentObject(session)) {
                    if session.content(project, list: column, card: card).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Image("empty")
                    } else {
                        Text(session.content(project, list: column, card: card))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(15)
                            .padding(.vertical, 8)
                    }
                }.listRowBackground(Color.clear)
    }
}
