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
            if model.lists == 2 {
                Items()
            }
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
                    }
                }
            }.background(Color("background")
                .cornerRadius(8))
                .accentColor(.clear)
        }.background(Color.clear)
            .accentColor(.clear)
    }
}

private struct Items: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        ForEach(0 ..< 2, id: \.self) { list in
            ForEach(0 ..< self.model.cards(list), id: \.self) { index in
                NavigationLink(destination:
                    Task(card: .init(list: list, index: index))
                        .environmentObject(self.model), tag: .init(list: list, index: index), selection: .init(self.$model.card)) {
                            Item(card: .init(list: list, index: index))
                }.background(Color.clear)
                    .accentColor(.clear)
            }
        }
    }
}

private struct Item: View {
    @EnvironmentObject var model: Model
    let card: Index
    
    var body: some View {
        HStack {
            Circle()
        }
    }
}
