import SwiftUI

struct Card: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        ScrollView {
            Header()
            Columns()
            Position()
            Stepper()
            Spacer()
                .frame(height: 25)
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
    }
}

private struct Header: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack {
            HStack {
                Back {
                    self.model.card = .null
                }
                Spacer()
            }
            Name(content: model.content(model.card))
        }
    }
}

private struct Name: View {
    @EnvironmentObject var model: Model
    @State var content: String
    @State private var deleting = false
    
    var body: some View {
        HStack {
            Button(action: {
                self.deleting = true
            }) {
                Image("delete")
                    .renderingMode(.original)
            }.background(Color.clear)
                .accentColor(.clear)
            TextField(.init("Card"), text: $content) {
                self.model.content(self.content)
            }.background(Color.clear)
                .accentColor(.clear)
        }.sheet(isPresented: $deleting) {
            if self.model.mode != .off {
                Button(.init("Delete.title.card.\(self.model.mode.rawValue)")) {
                    self.model.delete()
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
    
    var body: some View {
        ForEach(0 ..< model.lists, id: \.self) {
            Column(index: $0)
        }
    }
}

private struct Column: View {
    @EnvironmentObject var model: Model
    let index: Int
    
    var body: some View {
        HStack {
            if index == model.card.list {
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
                    self.model.move(list: self.index)
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
    
    var body: some View {
        HStack {
            Spacer()
            Text("\(model.card.index + 1)")
                .font(.title)
                .bold()
                .foregroundColor(Color("haze"))
            Text("/\(model.cards(model.card.list))")
                .font(.caption)
                .foregroundColor(Color("haze"))
            Spacer()
        }.offset(y: 20)
    }
}

private struct Stepper: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        HStack {
            Button(action: {
//                self.session.minus()
            }) {
                Image(systemName: "minus.circle.fill")
                    .resizable()
                    .foregroundColor(self.model.card.index == 0 ? Color("background") : Color("haze"))
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
                    .foregroundColor(self.model.card.index == self.model.cards(self.model.card.list) - 1 ? Color("background") : Color("haze"))
                    .frame(width: 40, height: 40)
            }.background(Color.clear)
                .accentColor(.clear)
                .padding(.trailing, 10)
        }
    }
}
