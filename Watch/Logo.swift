import SwiftUI

struct Logo: View {
    @State private var counter = -1
    @State private var timer: Timer?
    private let deg5 = Double(0.0872665)
    private let deg2_5 = Double(0.0436332)
    
    var body: some View {
        GeometryReader { geo in
            ForEach(0 ..< 36, id: \.self) { index in
                Path {
                    let prev = (self.deg2_5 / -2) + (self.deg5 * 2 * .init(index))
                    $0.addArc(center: .init(x: geo.size.width / 2, y: geo.size.height / 2),
                              radius: 30,
                              startAngle: .init(radians: prev),
                              endAngle: .init(radians: prev + self.deg2_5),
                              clockwise: false)
                }.stroke(index > self.counter ? Color("background") : Color("haze"), lineWidth: 3)
            }
        }.onAppear {
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if self.counter == 35 {
                    self.counter = -1
                } else {
                    self.counter += 1
                }
            }
        }.onDisappear {
            self.timer?.invalidate()
        }
    }
}
