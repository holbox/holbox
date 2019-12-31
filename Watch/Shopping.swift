import SwiftUI

struct Shopping: View {
    @State var groceries: [(String, String, String)]
    @State private var percent = Double()
    let project: Int
    
    var body: some View {
        ScrollView {
            Back(title: app.session.name(project))
            Stock(percent: $percent)
            Products(groceries: $groceries, project: project, refresh: refresh)
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
        
        withAnimation(.easeOut(duration: 0.5)) {
            percent = groceries.count > 0 ? .init(groceries.filter { $0.2 == "1" }.count) / .init(groceries.count) : 0
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
                .foregroundColor(.init("haze"))
                .opacity(stock ? 1 : 0)
            Text(emoji)
                .font(.title)
                .foregroundColor(.white)
                .opacity(stock ? 0.3 : 1)
            Text(description)
                .font(.footnote)
                .foregroundColor(.white)
                .opacity(stock ? 0.5 : 1)
            Spacer()
        }
    }
}

private struct Stock: View {
    @Binding var percent: Double
    
    var body: some View {
        ZStack {
            Path {
                $0.addRoundedRect(in: .init(x: 0, y: 0, width: 120, height: 12), cornerSize: .init(width: 6, height: 6))
            }.stroke(Color("haze"), style: .init(lineWidth: 1, lineCap: .round))
            Path {
                $0.move(to: .init(x: 1, y: 6))
                $0.addLine(to: .init(x: 118, y: 6))
            }.stroke(Color("haze"), style: .init(lineWidth: 5, dash: [1, 2], dashPhase: 10))
                .opacity(0.2)
            Stockin(percent: percent)
                .stroke(Color("haze"), style: .init(lineWidth: 5, dash: [1, 2], dashPhase: 10))
        }.frame(width: 120, height: 12)
            .padding(.init(top: 5, leading: 0, bottom: 15, trailing: 0))
    }
}

private struct Stockin: Shape {
    var percent: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .init(x: 1, y: 6))
        path.addLine(to: .init(x: 1 + .init(118 * percent), y: 6))
        return path
    }
    
    var animatableData: Double {
        get { percent }
        set { percent = newValue }
    }
}
