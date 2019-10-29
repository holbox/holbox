import SwiftUI

struct Card: View {
    @EnvironmentObject var session: Session
    
    var body: some View {
        List {
            Section(header: Header(content: session.content), footer: Footer()) {
                ForEach(0 ..< session.columns, id: \.self) {
                    Column(index: $0)
                }
            }
        }
    }
}

private struct Header: View {
    @EnvironmentObject var session: Session
    @State var content: String
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.session.item = nil
                }) {
                    Text(.init("Back"))
                        .font(.caption)
                }.accentColor(.clear)
                    .background(Color.clear)
                    .frame(width: 60, height: 40)
                Spacer()
            }
            TextField(.init("Card"), text: $content) {
                self.session.content(self.content)
            }.background(Color.clear)
                .accentColor(.clear)
                .padding(.bottom, 20)
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
                Text("\((session.item?.1 ?? 0) + 1)")
                    .font(.title)
                    .foregroundColor(Color("haze"))
                Text("/\(session.cards)")
                    .font(.caption)
                    .foregroundColor(Color("haze"))
                Spacer()
            }.padding(.top, 20)
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
                    .foregroundColor(session.item?.1 == 0 ? Color("background") : Color("haze"))
                    .frame(width: 40, height: 40)
            }
            Spacer()
            Button(action: {
                self.session.plus()
            }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .foregroundColor(session.item?.1 == session.cards - 1 ? Color("background") : Color("haze"))
                    .frame(width: 40, height: 40)
            }
            Spacer()
        }.padding(.top, 10)
    }
}

private struct Column: View {
    @EnvironmentObject var session: Session
    let index: Int
    
    var body: some View {
        HStack {
            if index == self.session.item!.0 {
                Text(session.list(index))
                    .foregroundColor(Color("haze"))
                    .bold()
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .foregroundColor(Color("haze"))
                    .frame(width: 20, height: 20)
                    .padding(.leading, 3)
            }
            else {
                Button(action: {
                    self.session.move(self.index)
                }) {
                    Text(session.list(index))
                        .foregroundColor(Color("haze"))
                        .bold()
                }.background(Color.clear)
                    .accentColor(.clear)
            }
        }.listRowBackground(Color.clear)
    }
}
