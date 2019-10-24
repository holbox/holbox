import SwiftUI

struct Card: View {
    @ObservedObject var global: Global
    @State var content: String
    @State var list: Int
    @State var card: Int
    @State private var moving = false
    
    var body: some View {
        VStack {
            TextField(.init("Card"), text: $content)
            NavigationLink(.init("Card.move"), destination: Move(global: global, list: list, card: card, current: list, update: {
                self.global.session.move(self.global.project!, list: self.list, card: self.card, destination: $0, index: $1)
                self.moving.toggle()
                self.list = $0
                self.card = $1
            }), isActive: $moving)
                .accentColor(.clear)
                .background(Color("background")
                    .cornerRadius(6))
                .foregroundColor(.white)
            Button(.init("Card.done")) {
                self.global.card = nil
                self.global.session.content(self.global.project!, list: self.list, card: self.card, content: self.content)
            }.accentColor(.clear)
                .background(Color("haze")
                    .cornerRadius(6))
                .foregroundColor(.black)
        }.navigationBarBackButtonHidden(true)
    }
}
