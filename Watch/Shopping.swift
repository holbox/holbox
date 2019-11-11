import SwiftUI

struct Shopping: View {
    @EnvironmentObject var model: Model
    @State private var name = ""
    
    var body: some View {
        ScrollView {
            Header(name: $name) {
                self.model.project = -1
            }
            Stack()
            Footer(name: $name, title: .init("Delete.title.\(model.mode.rawValue)"), placeholder: .init("Project"), delete: {
                self.model.delete()
            }) {
                self.model.name(self.name)
            }
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
            .onAppear {
                self.name = self.model.name(self.model.project)
        }
    }
}

private struct Stack: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack {
            Groceries()
            Text(.init("Shopping.products"))
                .font(Font.caption
                    .bold())
                .foregroundColor(Color("haze"))
                .opacity(0.6)
            Create()
            Products()
        }
    }
}

private struct Create: View {
    @EnvironmentObject var model: Model
    @State private var create = false
    
    var body: some View {
        Button(action: {
            self.create = true
        }) {
            Image("plusbig")
                .renderingMode(.original)
        }.sheet(isPresented: $create) {
            Stock(emoji: NSLocalizedString("Stock.add.emoji", comment: ""), label: NSLocalizedString("Stock.add.label", comment: ""), show: self.$create)
        }.background(Color.clear)
            .accentColor(.clear)
    }
}

private struct Groceries: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack {
            ForEach(0 ..< model.cards(1), id: \.self) {
                Grocery(index: $0)
            }
        }.padding(.vertical, 20)
    }
}

private struct Products: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack {
            ForEach(0 ..< model.cards(0), id: \.self) {
                Product(index: $0)
            }
        }
    }
}

private struct Grocery: View {
    @EnvironmentObject var model: Model
    let index: Int
    
    var body: some View {
        Button(action: {
//            self.model.delete(.init(list: 1, index: self.index))
        }) {
            HStack {
                Text(model.reference(index).0)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Text(model.reference(index).1)
                    .font(Font.subheadline
                        .bold())
                    .foregroundColor(Color("haze"))
                Spacer()
            }
        }.background(Color.clear)
            .accentColor(.clear)
    }
}

private struct Product: View {
    @EnvironmentObject var model: Model
    let index: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(model.product(index).0)
                    .font(.body)
                Text(model.product(index).1)
                    .font(.caption)
            }
            Spacer()
            Button(action: {
                
            }) {
                Icon(name: "pencil", width: 14, height: 14, color: "haze")
            }.background(Color.clear)
                .accentColor(.clear)
                .frame(width: 50)
            Button(action: {
                
            }) {
                Icon(name: "plus", width: 14, height: 14, color: model.active(index) ? "haze" : "background")
            }.background(Color.clear)
                .accentColor(.clear)
                .frame(width: 50)
        }.padding(.vertical, 10)
    }
}

private struct Stock: View {
    @EnvironmentObject var model: Model
    @State var emoji = ""
    @State var label = ""
    @Binding var show: Bool
    
    var body: some View {
        VStack {
                        TextField(.init("Task"), text: self.$emoji) {
                            self.show = false
        //                    if !self.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        //                        withAnimation(.linear(duration: 0.5)) {
        //                            self.model.addTask(self.emoji)
        //                            self.emoji = ""
        //                        }
        //                    }
                        }.background(Color("background")
                            .cornerRadius(8))
                            .accentColor(.clear)
                        TextField(.init("Task"), text: self.$label) {
                            self.show = false
        //                    if !self.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        //                        withAnimation(.linear(duration: 0.5)) {
        //                            self.model.addTask(self.label)
        //                            self.label = ""
        //                        }
        //                    }
                        }.background(Color("background")
                            .cornerRadius(8))
                            .accentColor(.clear)
                    }
    }
}
