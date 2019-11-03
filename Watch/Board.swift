import SwiftUI

struct Board: View {
    @EnvironmentObject var session: Session
    @State private var opacity = 1.0
    
    var body: some View {
        List {
            Header(name: session.name) {
                self.session.columns = 0
                withAnimation(.linear(duration: 0.3)) {
                    self.opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.session.project = nil
                }
            }
            if session.columns > 0 {
                ForEach(0 ..< session.columns, id: \.self) {
                    Column(column: $0)
                }
            }
        }.edgesIgnoringSafeArea(.top)
            .opacity(opacity)
            .transition(.move(edge: .bottom))
    }
}
private struct Header: View {
    @EnvironmentObject var session: Session
    @State var name: String
    var back: () -> Void
    
    var body: some View {
        Section(header:
            HStack {
                Back(action: back)
                TextField(.init("Kanban.project"), text: $name) {
                    self.session.name(self.name)
                }.background(Color.clear)
                    .accentColor(.clear)
                    .font(Font.body.bold())
                    .padding(.top, 20)
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
            withAnimation(.linear(duration: 0.4)) {
                self.session.card()
            }
        }) {
            HStack {
                Spacer()
                Image("card")
                Spacer()
            }
        }.listRowBackground(Color.clear)
            .padding(.top, 10)
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
                    .opacity(0.4))) {
                        ForEach(0 ..< self.session.cards(column), id: \.self) {
                            Item(column: self.column, card: $0)
                        }.onDelete {
                            self.session.delete(self.column, card: $0)
                        }
                        if session.cards(column) == 0 {
                            Spacer()
                                .listRowBackground(Color.clear)
                                .frame(height: 0)
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
            withAnimation(.linear(duration: 0.4)) {
                self.session.item = (self.column, self.card)
            }
        }) {
            if session.content(column, card: card).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Image("empty")
            } else {
                ForEach(session.content(column, card: card).mark { ($0, $1) }, id: \.1) {
                    Text(self.session.content(self.column, card: self.card)[$0.1])
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(30)
                        .font($0.0 == .plain ? .body : .title)
                }
            }
        }.listRowBackground(Color.clear)
            .padding(.top, 10)
    }
}
