import SwiftUI

struct Todo: View {
    @EnvironmentObject var model: Model
    @State private var name = ""
    
    var body: some View {
        ScrollView {
            Header(name: $name) {
                self.model.project = -1
            }
            Create()
            Tasks()
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

private struct Create: View {
    @EnvironmentObject var model: Model
    @State private var create = false
    @State private var content = ""
    
    var body: some View {
        Button(action: {
            self.create = true
        }) {
            Image("plusbig")
                .renderingMode(.original)
        }.sheet(isPresented: $create) {
            TextField(.init("Task"), text: self.$content) {
                self.create = false
                if !self.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    withAnimation(.linear(duration: 0.5)) {
                        self.model.addTask(self.content)
                        self.content = ""
                    }
                }
            }.background(Color("background")
                .cornerRadius(8))
                .accentColor(.clear)
        }.background(Color.clear)
            .accentColor(.clear)
    }
}

private struct Tasks: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        ForEach(0 ..< model.lists, id: \.self) { list in
            VStack {
                Column(list: list)
            }
        }
    }
}

private struct Column: View {
    @EnvironmentObject var model: Model
    let list: Int
    
    var body: some View {
        ForEach(0 ..< model.cards(list), id: \.self) { index in
            NavigationLink(destination:
                Task(card: .init(list: self.list, index: index))
                    .environmentObject(self.model), tag: .init(list: self.list, index: index), selection: .init(self.$model.card)) {
                        Items(card: .init(list: self.list, index: index))
            }.background(Color.clear)
                .accentColor(.clear)
        }
    }
}

private struct Items: View {
    @EnvironmentObject var model: Model
    let card: Index
    
    var body: some View {
        HStack {
            Icon(name: card.list == 0 ? "circle.fill" : "checkmark.circle.fill", width: 30, height: 30, color: card.list == 0 ? "background" : "haze")
                .frame(width: 30, height: 30)
            ForEach(model.marks(card), id: \.1) {
                Item(content: $0.0, mode: $0.1)
            }
            Spacer()
        }
    }
}
