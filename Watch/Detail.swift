import SwiftUI

struct Detail: View {
    @EnvironmentObject var session: Session
    
    var body: some View {
        List {
            if session.loading {
                Logo()
            } else {
                Projects()
            }
        }
    }
}

private struct Logo: View {
    var body: some View {
        HStack {
            Spacer()
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .padding(.top, 30)
            Spacer()
        }.listRowBackground(Color.clear)
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
        NavigationLink(session.name(index), destination:
            Board(project: index)
                .environmentObject(session))
            .listRowBackground(Color.clear)
    }
}

private struct Header: View {
    @EnvironmentObject var session: Session
    @State private var creating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Icon()
            New(creating: $creating)
        }.sheet(isPresented: $creating) {
            Add {
                self.creating.toggle()
                self.session.add()
            }.environmentObject(self.session)
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
                .frame(width: 80, height: 80)
            Spacer()
        }
    }
}

private struct New: View {
    @EnvironmentObject var session: Session
    @Binding var creating: Bool

    var body: some View {
        HStack {
            Text(.init("Detail.title.\(session.mode.rawValue)"))
                .font(Font.headline.bold())
                .foregroundColor(Color("haze")
                    .opacity(0.6))
            Button(action: {
                print("creating")
                self.creating.toggle()
            }) {
                Image("plus")
            }.padding(.leading, 10)
        }
    }
}
