import SwiftUI

struct Card: View {
    @EnvironmentObject var model: Model
    @State var card: Index
    
    var body: some View {
        ScrollView {
            Header(card: $card)
            Columns(card: $card)
            Position(card: $card)
            Stepper(card: $card)
            Spacer()
                .frame(height: 25)
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
    }
}

private struct Header: View {
    @EnvironmentObject var model: Model
    @Binding var card: Index
    
    var body: some View {
        VStack {
            HStack {
                Back {
                    self.model.card = .null
                }
                Spacer()
            }
            Name(card: $card, content: model.content(card))
                .padding(.bottom, 20)
        }
    }
}

private struct Name: View {
    @EnvironmentObject var model: Model
    @Binding var card: Index
    @State var content: String
    @State private var deleting = false
    
    var body: some View {
        HStack {
            TextField(.init("Card"), text: $content) {
                self.model.content(self.card, content: self.content)
            }.background(Color.clear)
                .accentColor(.clear)
            Button(action: {
                self.deleting = true
            }) {
                Image("delete")
                    .renderingMode(.original)
            }.background(Color.clear)
                .accentColor(.clear)
        }.sheet(isPresented: $deleting) {
            if self.model.mode != .off {
                Button(.init("Delete.title.card.\(self.model.mode.rawValue)")) {
                    self.model.delete(self.card)
                    self.deleting = false
                }.background(Color("haze")
                    .cornerRadius(8))
                    .accentColor(.clear)
                    .foregroundColor(.black)
                    .font(Font.headline.bold())
            }
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
                Image(systemName: "checkmark")
                    .resizable()
                    .foregroundColor(.black)
                    .frame(width: 10, height: 10)
                    .padding(.trailing, 4)
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
        }.offset(y: 15)
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
                Image(systemName: "minus.circle.fill")
                    .resizable()
                    .foregroundColor(card.index > 0 ? Color("haze") : Color("background"))
                    .frame(width: 40, height: 40)
            }.background(Color.clear)
                .accentColor(.clear)
                .padding(.leading, 10)
            Spacer()
            Button(action: {
                guard self.card.index < self.model.cards(self.card.list) - 1 else { return }
                self.model.move(self.card, index: self.card.index + 1)
                self.card = .init(list: self.card.list, index: self.card.index + 1)
            }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .foregroundColor(card.index == model.cards(card.list) - 1 ? Color("background") : Color("haze"))
                    .frame(width: 40, height: 40)
            }.background(Color.clear)
                .accentColor(.clear)
                .padding(.trailing, 10)
        }
    }
}
