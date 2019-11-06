import SwiftUI

struct Detail: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        ScrollView {
            VStack {
                Header()
                Projects()
            }
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
    }
}

private struct Header: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack {
            Title()
            New()
        }
    }
}

private struct Title: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        HStack {
            Back {
                self.model.mode = .off
            }
            if model.mode != .off {
                Text(.init("Detail.title.\(model.mode.rawValue)"))
                    .font(.headline)
                    .foregroundColor(Color("haze"))
                    .offset(x: -15)
            }
            Spacer()
        }
    }
}

private struct New: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        ZStack {
            if model.mode != .off {
                Image("detail.\(model.mode.rawValue)")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 70)
                    .offset(y: -20)
            }
            NavigationLink(destination: Circle(), isActive: $model.create) {
                Image("plus")
                    .renderingMode(.original)
            }.background(Color.clear)
                .accentColor(.clear)
                .offset(y: 10)
        }
    }
}

private struct Projects: View {

    var body: some View {
        Circle()
    }
}
/*
private struct Project: View {
    @EnvironmentObject var session: Session
    let index: Int
    
    var body: some View {
        Button(session.name(index)) {
            withAnimation(.linear(duration: 0.4)) {
                self.session.project = self.index
            }
        }.listRowBackground(Color.clear)
            .font(Font.body.bold())
            .foregroundColor(Color("haze"))
    }
}
*/
