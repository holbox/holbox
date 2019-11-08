import SwiftUI

struct Task: View {
    @EnvironmentObject var model: Model
    @State var card: Index
    @State private var content = ""
    
    var body: some View {
        ScrollView {
            Header(name: $content) {
                self.model.card = .null
            }
            Change(card: $card)
            Footer(name: $content, title: .init("Delete.title.card.\(self.model.mode.rawValue)"), placeholder: .init("Task"), delete: {
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

private struct Change: View {
    @EnvironmentObject var model: Model
    @Binding var card: Index
    @State private var disabled = false
    
    var body: some View {
        Button(action: {
            self.disabled = true
            self.model.move(self.card, list: self.card.list == 0 ? 1 : 0)
            withAnimation(.linear(duration: 0.6)) {
                self.card = .init(list: self.card.list == 0 ? 1 : 0, index: 0)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.disabled = false
            }
        }) {
            ZStack {
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .foregroundColor(Color("background"))
                    .frame(width: 45, height: 45)
                    .opacity(card.list == 0 ? 1 : 0)
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .foregroundColor(Color("haze"))
                    .frame(width: 45, height: 45)
                    .opacity(card.list == 0 ? 0 : 1)
            }
        }.background(Color.clear)
            .accentColor(.clear)
            .disabled(disabled)
    }
}
