import holbox
import SwiftUI

struct Detail: View {
    @EnvironmentObject var global: Global
    
    var body: some View {
        List {
            if global.session == nil {
                Logo()
            } else {
                Projects(items: global.session!.projects(global.mode))
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
    @State private var selected: Int?
    
    var body: some View {
        Section(header: Header(items: $items, selected: $selected)) {
            ForEach(items, id: \.self) {
                Project(active: self.selected == $0, index: $0)
            }.onDelete {
                self.global.session.delete(self.global.session!.projects(self.global.mode)[$0.first!])
                self.items = self.global.session!.projects(self.global.mode)
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
    @State var active: Bool
    let index: Int
    
    var body: some View {
        NavigationLink(global.session!.name(index), destination: Board().environmentObject(global), isActive: $active)
            .listRowBackground(Color.clear)
    }
}

private struct Header: View {
    @EnvironmentObject var global: Global
    @Binding var items: [Int]
    @Binding var selected: Int?
    @State private var creating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Detail()
            New(creating: $creating)
        }.sheet(isPresented: $creating) {
            Add {
                self.creating.toggle()
                self.global.session.add(self.global.mode)
                var items = self.global.session!.projects(self.global.mode)
                items.removeAll { $0 == 0 }
                items.insert(0, at: 0)
                self.items = items
                self.selected = 0
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
                self.creating.toggle()
            }) {
                Image("plus")
            }.padding(.leading, 10)
        }
    }
}
