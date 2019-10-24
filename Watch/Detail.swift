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
                    ForEach(self.global.session!.projects(self.global.mode), id: \.self) {
                        NavigationLink(self.global.session!.name($0), destination: Board(global: self.global), tag: $0, selection: self.$global.project)
                            .listRowBackground(Color("background").cornerRadius(6))
                    }.onDelete {
                        self.global.session.delete(self.global.session!.projects(self.global.mode)[$0.first!])
                        self.global.session = self.global.session
                    }
                }
            }
        }
        .sheet(isPresented: $creating) {
            Add(global: self.global) {
                self.creating.toggle()
                self.global.session.add(self.global.mode)   
            }
        }
    }
}
