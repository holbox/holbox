import SwiftUI

struct Shopping: View {
    @State var groceries: [(String, String, String)]
    let project: Int
    
    var body: some View {
        ScrollView {
            Back(title: app.session.name(project))
            Products(groceries: $groceries, project: project, refresh: refresh)
                .padding(.bottom, 20)
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.refresh()
                }
        }
    }
    
    private func refresh() {
        groceries = (0 ..< app.session.cards(project, list: 0)).map {
            (app.session.content(project, list: 0, card: $0),
             app.session.content(project, list: 1, card: $0),
             app.session.content(project, list: 2, card: $0))
        }
    }
}

private struct Products: View {
    @Binding var groceries: [(String, String, String)]
    let project: Int
    let refresh: () -> Void
    
    var body: some View {
        ForEach(0 ..< groceries.count, id: \.self) { index in
            Button(action: {
                app.session.content(self.project, list: 2, card: index, content: self.groceries[index].2 == "0" ? "1" : "0")
                self.refresh()
            }) {
                Product(stock: self.groceries[index].2 == "1", emoji: self.groceries[index].0, description: self.groceries[index].1)
            }.background(Color.clear)
                .accentColor(.clear)
        }
    }
}

private struct Product: View {
    let stock: Bool
    let emoji: String
    let description: String
    
    var body: some View {
        HStack {
            Image("check")
                .renderingMode(.template)
                .foregroundColor(Color("haze"))
                .opacity(stock ? 1 : 0)
            Text(emoji)
                .font(.title)
                .foregroundColor(.white)
            Text(description)
                .font(.caption)
                .foregroundColor(.white)
            Spacer()
        }
    }
}
