import SwiftUI

struct Bars: View {
    let project: Int
    @State private var cards = [Int]()
    @State private var top = CGFloat()
    @State private var counter = CGFloat(1)
    
    var body: some View {
        HStack {
            ForEach(0 ..< cards.count, id: \.self) { index in
                VStack {
                    Path {
                        $0.move(to: .init(x: 10, y: 60))
                        $0.addLine(to: .init(x: 10, y: max(60 - (.init(self.cards[index]) / self.counter * 60), 0)))
                    }.stroke(Color("haze"), style: .init(lineWidth: 6, lineCap: .round))
                        .frame(width: 20, height: 63)
                    Text(app.session.name(self.project, list: index))
                        .foregroundColor(.init("haze"))
                        .font(.footnote)
                    Text("\(self.cards[index])")
                        .foregroundColor(.init("haze"))
                        .font(.footnote)
                }
            }
        }.padding(.vertical, 25)
            .onAppear {
                self.cards = (0 ..< app.session.lists(self.project)).reduce(into: [Int]()) {
                    $0.append(app.session.cards(self.project, list: $1))
                }
                self.top = .init(self.cards.max() ?? 1)
                self.update()
        }
    }
    
    private func update() {
        if counter < top {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.counter += 1
                self.update()
            }
        }
    }
}
