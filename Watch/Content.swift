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
        }.edgesIgnoringSafeArea(.all)
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
        case .kanban:
            return .init(Kanban(cards: (0 ..< app.session.lists(project)).map { list in
                (0 ..< app.session.cards(project, list: list)).map { app.session.content(project, list: list, card: $0) }
            }, project: project))
        case .todo:
            return .init(Todo(
                waiting: (0 ..< app.session.cards(project, list: 0)).map { app.session.content(project, list: 0, card: $0) },
                done: (0 ..< app.session.cards(project, list: 1)).map { app.session.content(project, list: 1, card: $0) },
                project: project))
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
