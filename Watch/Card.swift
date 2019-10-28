/*import SwiftUI

struct Card: View {
    @EnvironmentObject var global: Global
    let position: Position
    //content: self.global.session.content(self.global.project!, list: list, card: card)
    var body: some View {
        List {
            Section(header: Circle(), footer: Circle()) {
                ForEach(0 ..< global.session.lists(global.project!), id: \.self) { index in
                    HStack {
                        if index == self.position.column {
                            Text(self.global.session.name(self.global.project!, list: index))
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .foregroundColor(Color("haze"))
                                .frame(width: 20, height: 20)
                        }
                        else {
                            Button(self.global.session.name(self.global.project!, list: index)) {
                                self.position.card = 0
                                self.position.column = index
                            }.background(Color.clear)
                                .accentColor(.clear)
                        }
                    }.listRowBackground(Color.clear)
                }
            }
        }
    }
}

private struct Header: View {
    @EnvironmentObject var global: Global
    @State var content: String
    
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
    @ObservedObject var position: Position
    
    var body: some View {
        VStack {
            HStack {
                Text(.init("Card.move.position"))
                    .font(Font.headline.bold())
                    .foregroundColor(Color("haze")
                        .opacity(0.6))
                Spacer()
                Text("\(position.card)")
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
*/
