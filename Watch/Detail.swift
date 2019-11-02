import SwiftUI

struct Detail: View {
    @EnvironmentObject var session: Session
    
    var body: some View {
        List {
            Projects()
        }.edgesIgnoringSafeArea(.top)
            .transition(.move(edge: .bottom))
    }
}

private struct Projects: View {
    @EnvironmentObject var session: Session
    
    var body: some View {
        Section(header: Header()) {
            ForEach(session.projects, id: \.self) {
                Project(index: $0)
            }.onDelete(perform: session.delete)
            if session.projects.isEmpty {
                Spacer()
                    .listRowBackground(Color.clear)
            }
        }
    }
}

private struct Project: View {
    @EnvironmentObject var session: Session
    let index: Int
    
    var body: some View {
        Button(session.name(index)) {
            withAnimation(.linear(duration: 0.4)) {
                self.session.project = self.index
            }
        }.listRowBackground(Color.clear)
            .font(Font.body.bold())
            .foregroundColor(Color("haze"))
    }
}

private struct Header: View {
    var body: some View {
        VStack {
            Icon()
            New()
        }
    }
}

private struct Icon: View {
    @EnvironmentObject var session: Session
    
    var body: some View {
        HStack {
            Spacer()
            Image("detail.\(session.mode.rawValue)")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 70, height: 50)
            Text(.init("Detail.title.\(session.mode.rawValue)"))
                .font(.headline)
                .foregroundColor(Color("haze"))
                .padding(.top, 20)
            Spacer()
        }
    }
}

private struct New: View {
    @EnvironmentObject var session: Session

    var body: some View {
        HStack {
            Button(action: {
                withAnimation(.linear(duration: 0.4)) {
                    self.session.more = true
                }
            }) {
                Image("more")
                    .renderingMode(.original)
            }.background(Color.clear)
                .accentColor(.clear)
            Spacer()
            Button(action: {
                withAnimation(.linear(duration: 0.4)) {
                    self.session.creating = true
                }
            }) {
                Image("plus")
                    .renderingMode(.original)
            }.background(Color.clear)
                .accentColor(.clear)
        }
    }
}
