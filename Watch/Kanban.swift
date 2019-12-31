import SwiftUI

struct Kanban: View {
    @State var cards: [[String]]
    @State private var top = 0
    @State private var total = 0
    let project: Int
    
    var body: some View {
        ScrollView {
            Back(title: app.session.name(project))
            Bars(cards: $cards, top: $top, total: $total, project: project)
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
        cards = (0 ..< app.session.lists(project)).map { list in
            (0 ..< app.session.cards(project, list: list)).map { app.session.content(project, list: list, card: $0) }
        }
        total = cards.map { $0.count }.reduce(0, +)
        withAnimation(.easeOut(duration: 0.5)) {
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
            HStack {
                Text(self.cards[self.list][card])
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(500)
                    .font(.caption)
                    .foregroundColor(.white)
                Spacer()
            }.padding(.vertical, 10)
        }
    }
}

private struct Bars: View {
    @Binding var cards: [[String]]
    @Binding var top: Int
    @Binding var total: Int
    let project: Int
    
    var body: some View {
        HStack {
            ForEach(0 ..< cards.count, id: \.self) { index in
                VStack {
                    Bar(percent: self.top > 0 ? .init(self.cards[index].count) / .init(self.top) : 0)
                        .stroke(Color("haze"),
                                style: .init(lineWidth: 9, lineCap: .round))
                        .frame(width: 30, height: 70)
                    Text("\(self.cards[index].count)")
                        .foregroundColor(.init("haze"))
                        .font(Font.body.bold())
                    Text("\(self.total > 0 ? Int(CGFloat(self.cards[index].count) / .init(self.total) * 100) : 0)%")
                        .foregroundColor(.init("haze"))
                        .font(.footnote)
                        .opacity(0.6)
                    Text(app.session.name(self.project, list: index))
                        .foregroundColor(.init("haze"))
                        .font(.footnote)
                        .opacity(0.6)
                }
            }
        }.padding(.init(top: 10, leading: 0, bottom: 35, trailing: 0))
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
