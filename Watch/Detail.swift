import SwiftUI

struct Detail: View {
    @ObservedObject var global: Global
    @State private var creating = false
    @State private var project: Int?
    
    var body: some View {
        List {
            if self.global.session == nil {
                HStack {
                    Spacer()
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .padding(.top, 20)
                    Spacer()
                }.listRowBackground(Color.clear)
            } else {
                Section(header:
                    VStack {
                        HStack {
                            Spacer()
                            Image("detail.\(self.global.mode.rawValue)")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 90, height: 90)
                            Spacer()
                        }
                        HStack {
                            Text(.init("Detail.title.\(self.global.mode.rawValue)"))
                                .font(.largeTitle)
                            Spacer()
                            Button(action: {
                                self.creating.toggle()
                            }) { Image("plus") }
                        }
                }) {
                    if project == nil {
                        ForEach(global.session!.projects(global.mode), id: \.self) {
                            NavigationLink(self.global.session!.name($0), destination: Board(global: self.global, name: self.global.session.name($0)), tag: $0, selection: self.$global.project)
                                .listRowBackground(Color("background").cornerRadius(6))
                        }.onDelete {
                            self.global.session.delete(self.global.session!.projects(self.global.mode)[$0.first!])
                            self.global.session = self.global.session
                        }
                        if global.session!.projects(global.mode).isEmpty {
                            Spacer()
                                .listRowBackground(Color.clear)
                        }
                    } else {
                        NavigationLink(global.session!.name(project!), destination: Board(global: global, name: global.session.name(project!)), tag: project!, selection: $project)
                            .listRowBackground(Color("background").cornerRadius(6)).onDisappear {
                                self.global.project = nil
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $creating) {
            Add(global: self.global) {
                self.creating.toggle()
                self.global.session.add(self.global.mode)
                self.global.session = self.global.session
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.project = 0
                    self.global.project = 0
                }
            }
        }
    }
}
