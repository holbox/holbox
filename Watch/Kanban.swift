import SwiftUI

struct Kanban: View {
    @State private var lists = 0
    let project: Int
    
    var body: some View {
        ScrollView {
            Back(title: app.session.name(project))
            Bars(project: project)
            Ring(current: app.session.cards(project, list: app.session.lists(project) - 1),
                 total: (0 ..< app.session.lists(project)).reduce(into: [Int]()) {
                    $0.append(app.session.cards(project, list: $1))
            }.reduce(0, +))
            HStack {
                Spacer()
                Button(action: {
                    app.session.add(self.project, list: 0)
                    self.lists = app.session.lists(self.project)
                }) {
                    Image("plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }.background(Color.clear)
                    .accentColor(.clear)
                Spacer()
            }
            Columns(lists: $lists, project: project)
                .padding(.vertical, 20)
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
            .onAppear {
                self.lists = app.session.lists(self.project)
        }
    }
}

private struct Columns: View {
    @Binding var lists: Int
    let project: Int
    
    var body: some View {
        ForEach(0 ..< lists) { list in
            VStack {
                Text(app.session.name(self.project, list: list))
                    .font(Font.caption.bold())
                    .foregroundColor(Color("haze"))
                    .padding(.bottom, 10)
                    .opacity(0.5)
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
                            .frame(width: 30, height: 3)
                            .padding(.vertical, 10)
                        Spacer()
                    }
                } else {
                    NavigationLink(destination: Circle()) {
                        Item(string: app.session.content(self.project, list: self.list, card: card))
                    }.background(Color.clear)
                        .accentColor(.clear)
                }
            }
        }
    }
}
