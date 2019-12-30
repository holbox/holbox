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
                        if app.session.projects().isEmpty {
                            _ = app.session.add(.kanban)
                        }
                        self.projects = app.session.projects()
                        self.loading = false
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
            return .init(Kanban(
                cards: (0 ..< app.session.lists(project)).map { list in
                    (0 ..< app.session.cards(project, list: list)).map { app.session.content(project, list: list, card: $0) }
            }, project: project))
        case .todo:
            return .init(Todo(
                waiting: (0 ..< app.session.cards(project, list: 0)).map { app.session.content(project, list: 0, card: $0) },
                done: (0 ..< app.session.cards(project, list: 1)).map { app.session.content(project, list: 1, card: $0) },
                project: project))
        case .shopping:
            return .init(Shopping(
                groceries: (0 ..< app.session.cards(project, list: 0)).map {
                    (app.session.content(project, list: 0, card: $0),
                     app.session.content(project, list: 1, card: $0),
                     app.session.content(project, list: 2, card: $0))
                },
                project: project))
        case .notes:
            return .init(Notes(project: project))
        default: return .init(Text(""))
        }
    }
}

private struct Project: View {
    let project: Int

    var body: some View {
        HStack {
            Rectangle()
                .foregroundColor(.init("haze"))
                .frame(width: 2, height: 20)
            Text(app.session.name(project))
                .foregroundColor(.init("haze"))
                .bold()
            Spacer()
        }
    }
}
