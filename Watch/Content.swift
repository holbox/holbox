import SwiftUI

struct Content: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        GeometryReader {
            if self.model.loading {
                Logo()
                    .frame(width: $0.size.width, height: $0.size.height)
            } else {
                Bar()
                    .frame(width: $0.size.width, height: $0.size.height)
            }
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
    }
}

private struct Bar: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack {
            NavigationLink(destination:
                Detail()
                    .environmentObject(model), tag: .kanban, selection: .init($model.mode)) {
                Image("kanban")
                    .renderingMode(.original)
            }.background(Color.clear)
                .accentColor(.clear)
            NavigationLink(destination:
                Detail()
                    .environmentObject(model), tag: .todo, selection: .init($model.mode)) {
                Image("todo")
                    .renderingMode(.original)
            }.background(Color.clear)
                .accentColor(.clear)
            NavigationLink(destination:
                About()
                    .environmentObject(model), isActive: $model.more) {
                Image("more")
                    .renderingMode(.original)
                    .opacity(0.5)
            }.background(Color.clear)
                .accentColor(.clear)
        }
    }
}
