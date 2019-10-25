import SwiftUI

struct Move: View {
    @ObservedObject var global: Global
    @State var list: Int
    @State var card: Int
    var current: Int
    var update: (Int, Int) -> Void
    
    var body: some View {
        List {
            Section(header:
                Text(.init("Card.move.title"))
                    .font(Font.headline.bold())) {
                ForEach(0 ..< global.session.lists(global.project!), id: \.self) { index in
                    HStack {
                        if index == self.list {
                            HStack {
                                Text(self.global.session.name(self.global.project!, list: index))
                                    .foregroundColor(.black)
                                    .frame(height: 35)
                                    .padding(.leading, 12)
                                Spacer()
                            }.background(Color("haze")
                                .cornerRadius(6))
                        }
                        else {
                            Button(self.global.session.name(self.global.project!, list: index)) {
                                self.card = 0
                                self.list = index
                            }.background(Color.clear)
                                .accentColor(.clear)
                            .padding(.leading, 12)
                        }
                    }.listRowBackground(Color.clear)
                }
            }
            Section(header:
                Text(.init("Card.move.position"))
                    .font(Font.headline.bold())) {
                ForEach(0 ..< global.session.cards(global.project!, list: list) + (list == current ? 0 : 1), id: \.self) { index in
                    HStack {
                        if index == self.card {
                            HStack {
                                Text("\(index + 1)")
                                    .foregroundColor(.black)
                                    .frame(height: 35)
                                    .padding(.leading, 12)
                                Spacer()
                            }.background(Color("haze")
                                .cornerRadius(6))
                        } else {
                            Button("\(index + 1)") {
                                self.card = index
                            }.background(Color.clear)
                                .accentColor(.clear)
                            .padding(.leading, 12)
                        }
                    }.listRowBackground(Color.clear)
                }
            }
            Button(.init("Card.move.done")) {
                self.update(self.list, self.card)
            }.listRowBackground(Color("haze")
                .cornerRadius(6))
                .foregroundColor(.black)
        }.navigationBarBackButtonHidden(true)
    }
}
