import SwiftUI

struct Detail: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        ScrollView {
            Title()
            Projects()
            Spacer()
                .frame(height: 30)
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
    }
}

private struct Title: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack {
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
            New()
        }
    }
}

private struct New: View {
    @EnvironmentObject var model: Model
    @State private var create = false
    
    var body: some View {
        ZStack {
            if model.mode != .off {
                Image("detail.\(model.mode.rawValue)")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 70)
                    .offset(y: -20)
            }
            Button(action: {
                self.create = true
            }) {
                Image("plus")
                    .renderingMode(.original)
            }.background(Color.clear)
                .accentColor(.clear)
                .offset(y: 10)
        }.sheet(isPresented: $create) {
            Add(create: self.$create)
                .environmentObject(self.model)
        }.padding(.bottom, 10)
    }
}

private struct Projects: View {
    @EnvironmentObject var model: Model

    var body: some View {
        ForEach(model.projects, id: \.self) { project in
            NavigationLink(destination:
            self.model.mode == .todo
                ? AnyView(Todo()
                    .environmentObject(self.model))
                : self.model.mode == .shopping
                    ? AnyView(Shopping()
                        .environmentObject(self.model))
                    : AnyView(Kanban()
                        .environmentObject(self.model)), tag: project, selection: .init(self.$model.project)) {
                Project(project: project)
            }.background(Color.clear)
                .accentColor(.clear)
        }
    }
}

private struct Project: View {
    @EnvironmentObject var model: Model
    let project: Int

    var body: some View {
        HStack {
            Circle()
                .foregroundColor(.init("haze"))
                .frame(width: 10, height: 10)
            Text(model.name(project))
                .foregroundColor(.init("haze"))
                .bold()
            Spacer()
        }
    }
}
