import SwiftUI

struct Card: View {
    @EnvironmentObject var model: Model
    @State var list: Int
    
    var body: some View {
        ScrollView {
            Header(list: $list)
            Move(list: $list)
            Spacer()
                .frame(height: 20)
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
    }
}

private struct Header: View {
    @EnvironmentObject var model: Model
    @Binding var list: Int
    @State var deleting = false
    
    var body: some View {
        VStack {
            Title(list: $list, content: model.content(list, card: model.card))
            Button(action: {
                self.deleting = true
            }) {
                Image("delete")
                    .renderingMode(.original)
            }.background(Color.clear)
                .accentColor(.clear)
                .padding(.top, 10)
        }.sheet(isPresented: $deleting) {
            if self.model.mode != .off {
                Button(.init("Delete.title.card.\(self.model.mode.rawValue)")) {
                    self.model.delete(self.list, card: self.model.card)
                    self.deleting = false
                    self.model.card = -1
                }.background(Color("haze")
                    .cornerRadius(8))
                    .accentColor(.clear)
                    .foregroundColor(.black)
                    .font(Font.headline.bold())
            }
        }
    }
}

private struct Title: View {
    @EnvironmentObject var model: Model
    @Binding var list: Int
    @State var content: String
    
    var body: some View {
        HStack {
            Back {
                self.model.card = -1
            }
            TextField(.init("Card"), text: $content) {
                self.model.content(self.list, self.model.card, self.content)
            }.background(Color.clear)
                .accentColor(.clear)
                .padding(.top, 15)
        }
    }
}

private struct Move: View {
    @EnvironmentObject var mode: Model
    @Binding var list: Int
    
    var body: some View {
        VStack {
            HStack {
                Text(.init("Card.move.title"))
                    .font(Font.caption
                        .bold())
                    .foregroundColor(Color("haze"))
                    .opacity(0.6)
                Spacer()
            }
            Columns(list: $list)
        }
    }
}

private struct Columns: View {
    @EnvironmentObject var model: Model
    @Binding var list: Int
    
    var body: some View {
        ForEach(0 ..< model.lists, id: \.self) {
            Column(list: self.$list, index: $0)
        }
    }
}

private struct Column: View {
    @EnvironmentObject var model: Model
    @Binding var list: Int
    let index: Int
    
    var body: some View {
        HStack {
            if index == list {
                Text(model.list(index))
                    .foregroundColor(Color("haze"))
                    .font(Font.subheadline
                        .bold())
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .foregroundColor(Color("haze"))
                    .frame(width: 20, height: 20)
                    .padding(.leading, 5)
                Spacer()
            } else {
                Button(action: {
//                    self.session.move(self.index)
                }) {
                    Text(model.list(index))
                        .foregroundColor(.white)
                        .font(Font.subheadline
                            .bold())
                    Spacer()
                    Spacer()
                }.background(Color.clear)
                    .accentColor(.clear)
            }
        }
    }
}

/*import SwiftUI

struct Card: View {
    @EnvironmentObject var session: Session
    @State private var opacity = 1.0
    
    var body: some View {
        List {
            Section(header: Header(content: session.content) {
                withAnimation(.linear(duration: 0.3)) {
                    self.opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.session.send()
                }
            }, footer: Footer()) {
                ForEach(0 ..< session.columns, id: \.self) {
                    Column(index: $0)
                }
            }
        }.edgesIgnoringSafeArea(.top)
            .opacity(opacity)
            .transition(.move(edge: .bottom))
    }
}

private struct Header: View {
    @EnvironmentObject var session: Session
    @State var content: String
    var back: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Back(action: back)
                TextField(.init("Card"), text: $content) {
                    self.session.content(self.content)
                }.background(Color.clear)
                    .accentColor(.clear)
                    .padding(.top, 20)
            }.padding(.bottom, 20)
            HStack {
                Text(.init("Card.move.title"))
                    .font(Font.headline.bold())
                    .foregroundColor(Color("haze")
                        .opacity(0.6))
                Spacer()
            }
        }
    }
}

private struct Footer: View {
    @EnvironmentObject var session: Session
    
    var body: some View {
        VStack {
            HStack {
                Text(.init("Card.move.position"))
                    .font(Font.headline.bold())
                    .foregroundColor(Color("haze")
                        .opacity(0.6))
                Spacer()
            }.padding(.top, 10)
            HStack(spacing: 0) {
                Spacer()
                Text("\((session.position?.1 ?? 0) + 1)")
                    .font(.title)
                    .bold()
                    .foregroundColor(Color("haze"))
                Text("/\(session.space)")
                    .font(.caption)
                    .foregroundColor(Color("haze"))
                Spacer()
            }
            Stepper()
        }
    }
}

private struct Stepper: View {
    @EnvironmentObject var session: Session
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                self.session.minus()
            }) {
                Image(systemName: "minus.circle.fill")
                    .resizable()
                    .foregroundColor(session.position?.1 == 0 ? Color("background") : Color("haze"))
                    .frame(width: 40, height: 40)
            }.background(Color.clear)
                .accentColor(.clear)
            Spacer()
            Button(action: {
                self.session.plus()
            }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .foregroundColor(session.position?.1 == session.space - 1 ? Color("background") : Color("haze"))
                    .frame(width: 40, height: 40)
            }.background(Color.clear)
                .accentColor(.clear)
            Spacer()
        }.padding(.bottom, 10)
    }
}


*/
