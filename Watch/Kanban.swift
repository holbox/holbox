import SwiftUI

struct Kanban: View {
    @State var cards: [[String]]
    @State private var top = 0
    let project: Int
    
    var body: some View {
        ScrollView {
            Back(title: app.session.name(project))
            Bars(cards: $cards, top: $top, project: project)
            Button(action: {
                app.session.add(self.project, list: 0)
                withAnimation {
                    self.refresh()
                }
            }) {
                Image("plus")
                    .renderingMode(.original)
            }.background(Color.clear)
                .accentColor(.clear)
            Columns(cards: $cards, project: project)
                .padding(.bottom, 20)
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.refresh()
                }
        }
    }
    
    private func refresh() {
        cards = (0 ..< app.session.lists(project)).reduce(into: [[String]]()) { outer, list in
            outer.append((0 ..< app.session.cards(project, list: list)).reduce(into: [String]()) {
                $0.append(app.session.content(project, list: list, card: $1))
            })
        }
        withAnimation(.easeOut(duration: 1.5)) {
            top = cards.map { $0.count }.max() ?? 0
        }
    }
}

private struct Columns: View {
    @Binding var cards: [[String]]
    let project: Int
    
    var body: some View {
        ForEach(0 ..< cards.count, id: \.self) { list in
            VStack {
                Text(app.session.name(self.project, list: list))
                    .font(Font.caption.bold())
                    .foregroundColor(Color("haze"))
                    .padding(.bottom, 10)
                    .opacity(0.6)
                Column(cards: self.$cards, project: self.project, list: list)
            }
        }
    }
}

private struct Column: View {
    @Binding var cards: [[String]]
    let project: Int
    let list: Int
    
    var body: some View {
        ForEach(0 ..< cards[list].count, id: \.self) { card in
            NavigationLink(destination: Card(card: card, list: self.list, project: self.project)) {
                if self.cards[self.list][card].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Circle()
                        .foregroundColor(.init("haze"))
                        .opacity(0.5)
                        .frame(width: 15, height: 15)
                } else {
                    VStack {
                        Item(string: self.cards[self.list][card])
                    }
                }
            }.background(Color.clear)
                .accentColor(.clear)
        }
    }
}

private struct Bars: View {
    @Binding var cards: [[String]]
    @Binding var top: Int
    let project: Int
    
    var body: some View {
        HStack {
            ForEach(0 ..< cards.count, id: \.self) { index in
                VStack {
                    Bar(percent: self.top > 0 ? .init(self.cards[index].count) / .init(self.top) : 0)
                        .stroke(Color("haze"),
                                style: .init(lineWidth: 6, lineCap: .round))
                        .frame(width: 20, height: 63)
                    Text(app.session.name(self.project, list: index))
                        .foregroundColor(.init("haze"))
                        .font(.footnote)
                    Text("\(self.cards[index].count)")
                        .foregroundColor(.init("haze"))
                        .font(.footnote)
                }
            }
        }.padding(.vertical, 25)
    }
}

private struct Bar: Shape {
    var percent: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .init(x: rect.midX, y: rect.maxY))
        path.addLine(to: .init(x: rect.midX, y: percent > 0 ? rect.height - (percent * rect.height) : rect.maxY))
        return path
    }
    
    var animatableData: CGFloat {
        get { percent }
        set { percent = newValue }
    }
}
