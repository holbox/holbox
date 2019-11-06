import SwiftUI

struct Detail: View {
    @EnvironmentObject var model: Model
    let projects: [Int]
    
    var body: some View {
        ScrollView {
            Header()
            Projects(projects: projects)
            Spacer()
                .frame(height: 100)
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
    }
}

private struct Header: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack {
            Title()
            New()
        }
    }
}

private struct Title: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        HStack {
            Back {
                self.model.mode = .off
            }
            if model.mode != .off {
                Text(.init("Detail.title.\(model.mode.rawValue)"))
                    .font(.headline)
                    .foregroundColor(Color("haze"))
                    .offset(x: -15)
            }
            Spacer()
        }
    }
}

private struct New: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        ZStack {
            if model.mode != .off {
                Image("detail.\(model.mode.rawValue)")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 70)
                    .offset(y: -20)
            }
            NavigationLink(destination: Circle(), isActive: $model.create) {
                Image("plus")
                    .renderingMode(.original)
            }.background(Color.clear)
                .accentColor(.clear)
                .offset(y: 10)
        }.padding(.bottom, 10)
    }
}

private struct Projects: View {
    @EnvironmentObject var model: Model
    @State private var project = -1
    let projects: [Int]

    var body: some View {
        ForEach(projects, id: \.self) { project in
            NavigationLink(destination:
                Kanban(project: self.$project)
                    .environmentObject(self.model), tag: project, selection: .init(self.$project)) {
                    HStack {
                        Circle()
                            .foregroundColor(.init("haze"))
                            .frame(width: 8, height: 8)
                            .padding(.leading, 10)
                        Text(self.model.name(project))
                            .foregroundColor(.init("haze"))
                            .bold()
                        Spacer()
                    }
            }.background(Color.clear)
                .accentColor(.clear)
        }
    }
}
