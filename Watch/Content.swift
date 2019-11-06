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

private struct Logo: View {
    var body: some View {
        HStack {
            Spacer()
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
            Spacer()
        }
    }
}

private struct Bar: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack {
            NavigationLink(destination: About().environmentObject(self.model), isActive: self.$model.more) {
                Image("kanban")
                    .renderingMode(.original)
            }.background(Color.clear)
                .accentColor(.clear)
            NavigationLink(destination: About().environmentObject(self.model), isActive: self.$model.more) {
                Image("todo")
                    .renderingMode(.original)
            }.background(Color.clear)
                .accentColor(.clear)
            NavigationLink(destination: About().environmentObject(self.model), isActive: self.$model.more) {
                Image("more")
                    .renderingMode(.original)
                    .opacity(0.5)
            }.background(Color.clear)
                .accentColor(.clear)
        }
    }
}
