import SwiftUI

struct Detail: View {
    @EnvironmentObject var global: Global
    
    var body: some View {
        List {
            if global.session == nil {
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
    @EnvironmentObject var global: Global
    
    var body: some View {
        Section(header: Header()) {
            ForEach(global.session!.projects(global.mode), id: \.self) {
                NavigationLink(self.global.session!.name($0), destination: Board().environmentObject(self.global), tag: $0, selection: self.$global.project)
                    .listRowBackground(Color.clear)
            }.onDelete {
                self.global.session.delete(self.global.session!.projects(self.global.mode)[$0.first!])
                self.global.session = self.global.session
            }
            if global.session!.projects(global.mode).isEmpty {
                Spacer()
                    .listRowBackground(Color.clear)
            }
        }
    }
}

private struct Header: View {
    @EnvironmentObject var global: Global
    @State private var creating = false
    
    var body: some View {
        VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Image("detail.\(self.global.mode.rawValue)")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                    Spacer()
                }
                HStack {
                    Text(.init("Detail.title.\(self.global.mode.rawValue)"))
                        .font(Font.headline.bold())
                        .foregroundColor(Color("haze")
                            .opacity(0.6))
                    Button(action: {
                        self.creating.toggle()
                    }) {
                        Image("plus")
                    }.padding(.leading, 10)
                }
        }.sheet(isPresented: $creating) {
            Add(global: self.global) {
                self.creating.toggle()
                self.global.session.add(self.global.mode)
                self.global.session = self.global.session
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if self.global.session.projects(self.global.mode).count == 1 {
                        self.global.project = 0
                    }
                }
            }
        }
    }
}
