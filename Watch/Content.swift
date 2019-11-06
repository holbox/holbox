import SwiftUI

struct Content: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        ZStack {
            Logo()
//            if !session.loading {
//                Bar()
//            }
        }.navigationBarHidden(true)
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
        }.listRowBackground(Color.clear)
    }
}

private struct Bar: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation(.linear(duration: 0.4)) {
//                    self.session.mode = .kanban
                }
            }) {
                Image("kanban")
                    .renderingMode(.original)
            }.background(Color.clear)
                .accentColor(.clear)
            Button(action: {
                withAnimation(.linear(duration: 0.4)) {
//                    self.session.mode = .todo
                }
            }) {
                Image("todo")
                    .renderingMode(.original)
            }.background(Color.clear)
                .accentColor(.clear)
            Button(action: {
                withAnimation(.linear(duration: 0.4)) {
//                    self.session.more = true
                }
            }) {
                Image("more")
                    .renderingMode(.original)
            }.background(Color.clear)
                .accentColor(.clear)
        }
    }
}
