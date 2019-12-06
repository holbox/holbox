import SwiftUI

struct Shopping: View {
    @State var products: [(String, String)]
    @State var references: [Int]
    let project: Int
    
    var body: some View {
        ScrollView {
            Back(title: app.session.name(project))
            Button(action: {
                app.session.add(self.project, emoji: NSLocalizedString("Stock.add.emoji", comment: ""),
                                description: NSLocalizedString("Stock.add.label", comment: ""))
                withAnimation {
                    self.refresh()
                }
            }) {
                Image("plus")
                    .renderingMode(.original)
            }.background(Color.clear)
                .accentColor(.clear)
            Products(products: $products, references: $references, project: project, refresh: refresh)
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
        products = (0 ..< app.session.cards(project, list: 0)).map { app.session.product(project, index: $0) }
        references = (0 ..< app.session.cards(project, list: 1)).map { Int(app.session.content(project, list: 1, card: $0))! }
    }
}

private struct Products: View {
    @Binding var products: [(String, String)]
    @Binding var references: [Int]
    let project: Int
    let refresh: () -> Void
    
    var body: some View {
        ForEach(0 ..< products.count, id: \.self) { index in
            Button(action: {
                if let reference = self.references.firstIndex(of: index) {
                    app.session.delete(self.project, list: 1, card: reference)
                } else {
                    app.session.add(self.project, reference: index)
                }
                self.refresh()
            }) {
                Product(stock: self.references.contains(index), emoji: self.products[index].0, description: self.products[index].1)
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
