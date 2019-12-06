import SwiftUI

struct Content: View {
    @State private var projects = [Int]()
    @State private var first = true
    @State private var loading = true
    
    var body: some View {
        Group {
            if loading {
                Logo()
            } else {
                ScrollView {
                    Projects(projects: $projects)
                }
            }
        }.edgesIgnoringSafeArea(.horizontal)
            .navigationBarHidden(true)
            .onAppear {
                if self.first {
                    self.first = false
                    app.session.load {
                        self.loading = false
                        self.projects = app.session.projects()
                    }
                } else {
                    self.projects = app.session.projects()
                }
        }
    }
}

private struct Projects: View {
    @Binding var projects: [Int]

    var body: some View {
        ForEach(projects, id: \.self) { project in
            NavigationLink(destination: Projects.factory(project)) {
                Project(project: project)
            }.listRowInsets(.none)
                .background(Color.clear)
                .accentColor(.clear)
        }
    }
    
    private static func factory(_ project: Int) -> AnyView {
        switch app.session.mode(project) {
        case .kanban: return .init(Kanban(cards: (0 ..< app.session.lists(project)).reduce(into: [[String]]()) { outer, list in
            outer.append((0 ..< app.session.cards(project, list: list)).reduce(into: [String]()) {
                $0.append(app.session.content(project, list: list, card: $1))
            })
        }, project: project))
        default: return .init(Circle())
        }
    }
}

private struct Project: View {
    let project: Int

    var body: some View {
        HStack {
            Rectangle()
                .foregroundColor(.init("haze"))
                .frame(width: 2, height: 30)
            Text(app.session.name(project))
                .foregroundColor(.init("haze"))
                .bold()
            Spacer()
        }
    }
}
