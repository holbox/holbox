import SwiftUI

struct Detail: View {
    @ObservedObject var global: Global
    @State private var creating = false
    
    var body: some View {
        GeometryReader { geo in
            List {
                Section(header:
                    VStack {
                        HStack {
                            Spacer()
                                
                            Image("detail.\(self.global.mode.rawValue)")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geo.size.height * 0.5, height: geo.size.height * 0.5)
                            
                                
                            Spacer()
                        }
                        
                        HStack {
                            Text(.init("Detail.title.\(self.global.mode.rawValue)")).font(.largeTitle)
                            
                            Spacer()
                            
                            Image("plus")
                        }.onTapGesture { self.creating.toggle() }
                }) {
                    ForEach(self.global.session?.projects(self.global.mode) ?? [], id: \.self) { project in
                        NavigationLink(self.global.session!.name(project), destination: Board(global: self.global), tag: project, selection: self.$global.project)
                    }
                }
            }
        }
        .sheet(isPresented: $creating) { Add(global: self.global) {
            self.creating.toggle()
            self.global.session.add(self.global.mode)
        } }
    }
}
