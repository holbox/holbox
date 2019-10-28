import holbox
import SwiftUI

struct Detail: View {
    @EnvironmentObject var global: Global
    
    var body: some View {
        List {
            if global.session == nil {
                Logo()
            } else {
                Projects(items: global.session.projects(global.mode))
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
    @EnvironmentObject var global: Global
    @State var items: [Int]
    
    var body: some View {
        Section(header: Header(items: $items)) {
            ForEach(items, id: \.self) {
                Project(name: self.global.session.name($0), index: $0)
            }.onDelete {
                self.global.session.delete(self.global.session.projects(self.global.mode)[$0.first!])
                self.items = self.global.session.projects(self.global.mode)
            }
            if items.isEmpty {
                Spacer()
                    .listRowBackground(Color.clear)
            }
        }
    }
}

private struct Project: View {
    @EnvironmentObject var global: Global
    @State var name: String
    let index: Int
    
    var body: some View {
        NavigationLink(name, destination:
            Board(name: $name, project: index)
                .environmentObject(global))
            .listRowBackground(Color.clear)
    }
}

private struct Header: View {
    @EnvironmentObject var global: Global
    @Binding var items: [Int]
    @State private var creating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Icon()
            New(creating: $creating)
        }.sheet(isPresented: $creating) {
            Add {
                self.creating.toggle()
                self.global.session.add(self.global.mode)
                var items = self.global.session.projects(self.global.mode)
                items.removeAll { $0 == 0 }
                items.insert(0, at: 0)
                self.items = items
            }.environmentObject(self.global)
        }
    }
}

private struct Icon: View {
    @EnvironmentObject var global: Global
    
    var body: some View {
        HStack {
            Spacer()
            Image("detail.\(global.mode.rawValue)")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
            Spacer()
        }
    }
}

private struct New: View {
    @EnvironmentObject var global: Global
    @Binding var creating: Bool

    var body: some View {
        HStack {
            Text(.init("Detail.title.\(global.mode.rawValue)"))
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
