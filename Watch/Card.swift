/*import SwiftUI

struct Card: View {
    @EnvironmentObject var model: Model
    @State var card: Index
    @State private var content = ""
    
    var body: some View {
        ScrollView {
            Header(name: $content) {
                self.model.card = .null
            }
            Columns(card: $card)
            Position(card: $card)
            Stepper(card: $card)
            Footer(name: $content, title: .init("Delete.title.card.\(self.model.mode.rawValue)"), placeholder: .init("Card"), delete: {
                self.model.delete(self.card)
            }) {
                self.model.content(self.card, content: self.content)
            }
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
            .onAppear {
                self.content = self.model.content(self.card)
        }
    }
}

private struct Columns: View {
    @EnvironmentObject var model: Model
    @Binding var card: Index
    
    var body: some View {
        ForEach(0 ..< model.lists, id: \.self) {
            Column(card: self.$card, index: $0)
        }
    }
}

private struct Column: View {
    @EnvironmentObject var model: Model
    @Binding var card: Index
    let index: Int
    
    var body: some View {
        Button(action: {
            if self.index != self.card.list {
                self.model.move(self.card, list: self.index)
                self.card = .init(list: self.index, index: 0)
            }
        }) {
            HStack {
                Text(model.list(index))
                    .foregroundColor(index == card.list ? .black : Color("haze"))
                    .font(Font.subheadline
                        .bold())
                Spacer()
                Icon(name: "checkmark", width: 10, height: 10, color: "background")
                    .padding(.trailing, 4)
                    .foregroundColor(.black)
                    .opacity(index == card.list ? 1 : 0)
            }
        }.background(index == card.list ? Color("haze")
            .cornerRadius(10) : Color("background")
                .cornerRadius(10))
            .accentColor(.clear)
            .padding(.horizontal, 15)
    }
}

private struct Position: View {
    @EnvironmentObject var model: Model
    @Binding var card: Index
    
    var body: some View {
        HStack {
            Spacer()
            Text("\(card.index + 1)")
                .font(.title)
                .bold()
                .foregroundColor(Color("haze"))
            Text("/\(model.cards(card.list))")
                .font(.caption)
                .foregroundColor(Color("haze"))
            Spacer()
        }.padding(.top, 20)
    }
}

private struct Stepper: View {
    @EnvironmentObject var model: Model
    @Binding var card: Index
    
    var body: some View {
        HStack {
            Button(action: {
                guard self.card.index > 0 else { return }
                self.model.move(self.card, index: self.card.index - 1)
                self.card = .init(list: self.card.list, index: self.card.index - 1)
            }) {
                Icon(name: "minus.circle.fill", width: 35, height: 35, color: card.index > 0 ? "haze" : "background")
            }.background(Color.clear)
                .accentColor(.clear)
                .padding(.leading, 10)
            Spacer()
            Button(action: {
                guard self.card.index < self.model.cards(self.card.list) - 1 else { return }
                self.model.move(self.card, index: self.card.index + 1)
                self.card = .init(list: self.card.list, index: self.card.index + 1)
            }) {
                Icon(name: "plus.circle.fill", width: 35, height: 35, color: card.index == model.cards(card.list) - 1 ? "background" : "haze")
            }.background(Color.clear)
                .accentColor(.clear)
                .padding(.trailing, 10)
        }
    }
}
*/
