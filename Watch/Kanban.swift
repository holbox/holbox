import SwiftUI

struct Kanban: View {
    @State private var creating = false
    let project: Int
    
    var body: some View {
        ScrollView {
            if !creating {
                Back(title: app.session.name(project))
                Bars(project: project)
                Ring(current: app.session.cards(project, list: app.session.lists(project) - 1),
                     total: (0 ..< app.session.lists(project)).reduce(into: [Int]()) {
                        $0.append(app.session.cards(project, list: $1))
                }.reduce(0, +))
            }
            Button(action: {
                app.session.add(self.project, list: 0)
                withAnimation {
                    self.creating.toggle()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    withAnimation {
                        self.creating.toggle()
                    }
                }
            }) {
                Image("plus")
                    .renderingMode(.original)
            }.background(Color.clear)
                .accentColor(.clear)
            if !creating {
                Columns(project: project)
            }
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
    }
}

private struct Columns: View {
    let project: Int
    
    var body: some View {
        ForEach(0 ..< app.session.lists(project), id: \.self) { list in
            VStack {
                Text(app.session.name(self.project, list: list))
                    .font(Font.caption.bold())
                    .foregroundColor(Color("haze"))
                    .padding(.bottom, 10)
                    .opacity(0.6)
                Column(project: self.project, list: list)
            }
        }
    }
}

private struct Column: View {
    let project: Int
    let list: Int
    
    var body: some View {
        ForEach(0 ..< app.session.cards(self.project, list: self.list), id: \.self) { card in
            NavigationLink(destination: Card(card: card, list: self.list, project: self.project)) {
                if app.session.content(self.project, list: self.list, card: card).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    HStack {
                        Rectangle()
                            .foregroundColor(.init("haze"))
                            .opacity(0.4)
                            .frame(width: 50, height: 3)
                        Spacer()
                    }
                } else {
                    VStack {
                        Item(string: app.session.content(self.project, list: self.list, card: card))
                    }
                }
            }.background(Color.clear)
                .accentColor(.clear)
        }
    }
}
