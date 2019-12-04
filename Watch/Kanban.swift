import SwiftUI

struct Kanban: View {
    let project: Int
    
    var body: some View {
        ScrollView {
            Back(title: app.session.name(project))
            Bars(project: project)
            Ring(current: app.session.cards(project, list: app.session.lists(project) - 1),
                 total: (0 ..< app.session.lists(project)).reduce(into: [Int]()) {
                    $0.append(app.session.cards(project, list: $1))
            }.reduce(0, +))
            Columns(project: project, lists: app.session.lists(project))
                .padding(.vertical, 20)
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
    }
}

private struct Columns: View {
    let project: Int
    let lists: Int
    
    var body: some View {
        ForEach(0 ..< lists) { list in
            VStack {
                Text(app.session.name(self.project, list: list))
                    .bold()
                Column(project: self.project, list: list)
            }
        }
    }
}

private struct Column: View {
    let project: Int
    let list: Int
    
    var body: some View {
        ForEach(0 ..< app.session.cards(self.project, list: self.list)) { card in
            VStack {
                if app.session.content(self.project, list: self.list, card: card).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    HStack {
                        Rectangle()
                            .foregroundColor(.init("haze"))
                            .frame(width: 30, height: 2)
                        Spacer()
                    }
                } else {
                    Item(string: app.session.content(self.project, list: self.list, card: card))
                }
            }
        }
    }
}
