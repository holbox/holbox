import SwiftUI

struct Card: View {
    @EnvironmentObject var model: Model
    @State var list: Int
    
    var body: some View {
        ScrollView {
            Header(list: $list)
            Columns(list: $list)
            Position(list: $list)
            Stepper(list: $list)
            Spacer()
                .frame(height: 25)
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
            Back {
                self.model.card = -1
            }
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
                    .padding(.leading, 15)
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .foregroundColor(Color("haze"))
                    .frame(width: 15, height: 15)
                    .padding(.leading, 2)
                Spacer()
            } else {
                Button(action: {
                    self.model.move(self.list, listB: self.index)
                    self.list = self.index
                }) {
                    Text(model.list(index))
                        .foregroundColor(.white)
                        .font(Font.subheadline
                            .bold())
                    Spacer()
                }.background(Color.clear)
                    .accentColor(.clear)
            }
        }
    }
}

private struct Position: View {
    @EnvironmentObject var model: Model
    @Binding var list: Int
    
    var body: some View {
        HStack {
            Spacer()
            Text("\(model.card + 1)")
                .font(.title)
                .bold()
                .foregroundColor(Color("haze"))
            Text("/\(model.cards(list))")
                .font(.caption)
                .foregroundColor(Color("haze"))
            Spacer()
        }.offset(y: 20)
    }
}

private struct Stepper: View {
    @EnvironmentObject var model: Model
    @Binding var list: Int
    
    var body: some View {
        HStack {
            Button(action: {
//                self.session.minus()
            }) {
                Image(systemName: "minus.circle.fill")
                    .resizable()
                    .foregroundColor(self.model.card == 0 ? Color("background") : Color("haze"))
                    .frame(width: 40, height: 40)
            }.background(Color.clear)
                .accentColor(.clear)
                .padding(.leading, 10)
            Spacer()
            Button(action: {
//                self.session.plus()
            }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .foregroundColor(self.model.card == self.model.cards(self.list) - 1 ? Color("background") : Color("haze"))
                    .frame(width: 40, height: 40)
            }.background(Color.clear)
                .accentColor(.clear)
                .padding(.trailing, 10)
        }
    }
}
