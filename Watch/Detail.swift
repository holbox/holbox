import SwiftUI

struct Detail: View {
    @ObservedObject var global: Global
    @State private var creating = false
    
    var body: some View {
        List {
            if self.global.session == nil {
                HStack {
                    Spacer()
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .padding(.top, 30)
                    Spacer()
                }.listRowBackground(Color.clear)
            } else {
                Section(header:
                    VStack(spacing: 10) {
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
                            Spacer()
                            Button(action: {
                                self.creating.toggle()
                            }) { Image("plus") }
                        }
                }) {
                    ForEach(global.session!.projects(global.mode), id: \.self) {
                        NavigationLink(self.global.session!.name($0), destination: Board(global: self.global, name: self.global.session.name($0)), tag: $0, selection: self.$global.project)
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
        .sheet(isPresented: $creating) {
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
