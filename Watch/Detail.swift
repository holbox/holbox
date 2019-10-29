import SwiftUI

struct Detail: View {
    @EnvironmentObject var session: Session
    
    var body: some View {
        List {
            Projects()
        }
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
            self.session.project = self.index
        }.listRowBackground(Color.clear)
            .font(.headline)
            .foregroundColor(Color("haze"))
    }
}

private struct Header: View {
    var body: some View {
        VStack(spacing: 20) {
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
                .frame(width: 70, height: 70)
            Spacer()
        }
    }
}

private struct New: View {
    @EnvironmentObject var session: Session

    var body: some View {
        HStack {
            Text(.init("Detail.title.\(session.mode.rawValue)"))
                .font(Font.headline.bold())
                .foregroundColor(Color("haze")
                    .opacity(0.6))
            Button(action: {
                self.session.creating = true
            }) {
                Image("plus")
            }.padding(.horizontal, 10)
            Button(action: {
                self.session.more = true
            }) {
                Image("more")
            }.padding(.leading, 10)
        }.padding(.bottom, 10)
    }
}
