import SwiftUI

struct Add: View {
    @EnvironmentObject var session: Session
    @State private var opacity = 1.0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Header()
                Available()
                if session.available > 0 {
                    Create {
                        withAnimation(.linear(duration: 0.3)) {
                            self.opacity = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            withAnimation(.linear(duration: 0.4)) {
                                self.session.add()
                            }
                        }
                    }
                } else {
                    Text(.init("Add.other"))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(10)
                        .opacity(0.6)
                }
                Cancel {
                    withAnimation(.linear(duration: 0.3)) {
                        self.opacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        self.session.creating = false
                    }
                }
            }
        }.background(Color.black)
            .opacity(opacity)
            .edgesIgnoringSafeArea(.all)
            .transition(.move(edge: .bottom))
    }
}

private struct Header: View {
    var body: some View {
        HStack {
            Spacer()
            Image("new")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .padding(.top, 10)
            Spacer()
        }
    }
}

private struct Available: View {
    @EnvironmentObject var session: Session
    
    var body: some View {
        VStack {
            Text(.init("Add.title.\(session.mode.rawValue)"))
                .font(.headline)
            Text(.init("Add.subtitle.other"))
                .opacity(0.4)
            Text("\(session.available)")
                .font(.largeTitle)
                .foregroundColor(Color("haze"))
        }
    }
}

private struct Create: View {
    @EnvironmentObject var session: Session
    var create: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: create) {
                Text(.init("Add.title.\(self.session.mode.rawValue)"))
                    .foregroundColor(.black)
                    .fontWeight(.bold)
            }.background(Color("haze")
                .cornerRadius(6))
                .accentColor(.clear)
                .frame(minWidth: 120)
            Spacer()
        }
    }
}

private struct Cancel: View {
    @EnvironmentObject var session: Session
    var cancel: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: cancel) {
                Text(.init("Add.cancel"))
                    .foregroundColor(.white)
            }.background(Color.clear)
                .accentColor(.clear)
                .frame(minWidth: 120)
            Spacer()
        }.padding(.bottom, 20)
    }
}
