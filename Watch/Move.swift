import SwiftUI

struct Move: View {
    @ObservedObject var global: Global
    @ObservedObject var position: Position
    let current: Int
    
    var body: some View {
        Circle()
//        List {
//            Button(action: {
//
//            }) { () -> PrimitiveButtonStyleConfiguration.Label in
//
//            }
//            Section(header:
//                Text(.init("Card.move.title"))
//                    .font(Font.headline.bold())
//                    .foregroundColor(Color("haze")
//                        .opacity(0.6))) {
//                ForEach(0 ..< global.session.lists(global.project!), id: \.self) { index in
//                    HStack {
//                        if index == self.position.column {
//                            Text(self.global.session.name(self.global.project!, list: index))
//                            Image(systemName: "checkmark.circle.fill")
//                                .resizable()
//                                .foregroundColor(Color("haze"))
//                                .frame(width: 20, height: 20)
//                        }
//                        else {
//                            Button(self.global.session.name(self.global.project!, list: index)) {
//                                self.position.card = 0
//                                self.position.column = index
//                            }.background(Color.clear)
//                                .accentColor(.clear)
//                        }
//                    }.listRowBackground(Color.clear)
//                }
//            }
//            Section(header:
//                Text(.init("Card.move.position"))
//                    .font(Font.headline.bold())) {
//                ForEach(0 ..< global.session.cards(global.project!, list: list) + (list == current ? 0 : 1), id: \.self) { index in
//                    HStack {
//                        if index == self.card {
//                            HStack {
//                                Text("\(index + 1)")
//                                    .foregroundColor(.black)
//                                    .frame(height: 35)
//                                    .padding(.leading, 12)
//                                Spacer()
//                            }.background(Color("haze")
//                                .cornerRadius(6))
//                        } else {
//                            Button("\(index + 1)") {
//                                self.card = index
//                            }.background(Color.clear)
//                                .accentColor(.clear)
//                            .padding(.leading, 12)
//                        }
//                    }.listRowBackground(Color.clear)
//                }
//            }
//        }
    }
}
