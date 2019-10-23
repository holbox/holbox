import SwiftUI

final class Kanban: WKHostingController<KanbanView> {
    override var body: KanbanView { .init() }
}

struct KanbanView: View {
    @State private var creating = false
    
    var body: some View {
        GeometryReader { geo in
            List {
                Section(header: VStack {
                    HStack {
                        Spacer()
                            
                        Image("detail.1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geo.size.height * 0.5, height: geo.size.height * 0.5)
                        
                            
                        Spacer()
                    }
                    
                    HStack {
                        Text("Detail.title.1").font(.largeTitle)
                        
                        Spacer()
                        
                        Image("plus")
                    }.onTapGesture { self.creating.toggle() }
                }) {
                    Text("Project A")
                    Text("Project B")
                }
            }
        }
        .sheet(isPresented: $creating) { Add() }
    }
}
