import SwiftUI

struct Card: View {
    @EnvironmentObject var session: Session
    @Binding var column: Int
    @Binding var card: Int
    let project: Int
    
    var body: some View {
        List {
            Section(header: Circle(), footer: Circle()) {
                ForEach(0 ..< session.lists(project), id: \.self) {
                    Column(column: self.$column, card: self.$card, index: $0, project: self.project)
                }
            }
        }
    }
}

private struct Header: View {
    @EnvironmentObject var session: Session
    @Binding var column: Int
    @Binding var card: Int
    @State var content: String
    let project: Int
    
    var body: some View {
        VStack {
            TextField(.init("Card"), text: $content) {
                print("commit")
                print(self.content)
            }.background(Color.clear)
                .accentColor(Color.clear)
                .listRowBackground(Color("background")
                    .cornerRadius(6))
                .listRowInsets(.init())
            Text(.init("Card.move.title"))
                .font(Font.headline.bold())
                .foregroundColor(Color("haze")
                    .opacity(0.6))
        }
    }
}


private struct Footer: View {
    @EnvironmentObject var session: Session
    @Binding var column: Int
    @Binding var card: Int
    let index: Int
    let project: Int
    
    var body: some View {
        VStack {
            HStack {
                Text(.init("Card.move.position"))
                    .font(Font.headline.bold())
                    .foregroundColor(Color("haze")
                        .opacity(0.6))
                Spacer()
                Text("\(card)")
                    .font(.title)
                    .foregroundColor(Color("haze"))
                Text("1")
                    .font(.caption)
                    .foregroundColor(Color("haze"))
            }
//            HStack {
//                Spacer()
//                Button(action: {
//                    print("minus")
//                }) {
//                    Image(systemName: "minus.circle.fill")
//                        .resizable()
//                        .foregroundColor(Color("haze"))
//                        .frame(width: 40, height: 40)
//                }.buttonStyle(PlainButtonStyle())
//                Spacer()
//                Button(action: {
//                    print("plus")
//                }, label: {
//                    Image(systemName: "plus.circle.fill")
//                        .resizable()
//                        .renderingMode(.original)
//                        .foregroundColor(Color("haze"))
//                        .frame(width: 40, height: 40)
//                })
//                Spacer()
//            }
        }
    }
}

private struct Column: View {
    @EnvironmentObject var session: Session
    @Binding var column: Int
    @Binding var card: Int
    let index: Int
    let project: Int
    
    var body: some View {
        HStack {
            if index == column {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .foregroundColor(Color("haze"))
                    .frame(width: 20, height: 20)
                    .padding(.horizontal, 10)
                Text(session.name(project, list: index))
            }
            else {
                Button(session.name(project, list: index)) {
                    let column = self.column
                    let card = self.card
                    self.card = 0
                    self.column = self.index
                    self.session.move(self.project, list: column, card: card, destination: self.column, index: self.card)
                }.background(Color.clear)
                    .accentColor(.clear)
            }
        }.listRowBackground(Color.clear)
    }
}
