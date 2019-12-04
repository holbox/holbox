import SwiftUI

struct Ring: View {
    let current: Int
    let total: Int
    @State private var counter = 0
    @State private var amount = Double()
    private let formatter = NumberFormatter()
    
    var body: some View {
        ZStack {
            Path {
                $0.addArc(center: .init(x: 55, y: 55),
                    radius: 40,
                    startAngle: .init(degrees: 0),
                    endAngle: .init(degrees: 360),
                    clockwise: false)
            }.stroke(Color("haze"), lineWidth: 4)
                .opacity(0.2)
            Path {
                $0.addArc(center: .init(x: 55, y: 55),
                    radius: 40,
                    startAngle: .init(degrees: -90),
                    endAngle: .init(degrees: (360 * self.amount) - 90),
                    clockwise: false)
            }.stroke(Color("haze"), style: .init(lineWidth: 8, lineCap: .round))
            Text(self.formatter.string(from: NSNumber(value: self.amount))!)
                .foregroundColor(.init("haze"))
                .bold()
        }.frame(width: 110, height: 110)
            .onAppear {
            self.formatter.numberStyle = .percent
            self.update()
        }
    }
    
    private func update() {
        amount = .init(counter) / .init(total > 0 ? total : 1)
        if counter < current {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.counter += 1
                self.update()
            }
        }
    }
}
