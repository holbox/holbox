import SwiftUI

struct Todo: View {
    @State var waiting: [String]
    @State var done: [String]
    @State private var percent = Double()
    let project: Int
    
    var body: some View {
        ScrollView {
            Back(title: app.session.name(project))
            Ring(percent: $percent)
            Button(action: {
                app.session.add(self.project, list: 0)
                withAnimation {
                    self.refresh()
                }
            }) {
                Image("plus")
                    .renderingMode(.original)
            }.background(Color.clear)
                .accentColor(.clear)
            Tasks(waiting: $waiting, done: $done)
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.refresh()
                }
        }
    }
    
    private func refresh() {
        waiting = (0 ..< app.session.cards(project, list: 0)).map { app.session.content(project, list: 0, card: $0) }
        done = (0 ..< app.session.cards(project, list: 1)).map { app.session.content(project, list: 1, card: $0) }
        let count = Double(waiting.count + done.count)
        withAnimation(.easeOut(duration: 1.5)) {
            percent = count > 0 ? .init(waiting.count) / count : 0
        }
    }
}

private struct Tasks: View {
    @Binding var waiting: [String]
    @Binding var done: [String]
    
    var body: some View {
        VStack {
            ForEach(0 ..< waiting.count, id: \.self) { index in
                Button(action: {
                    
                }) {
                    Waiting(task: self.waiting[index])
                }.background(Color.clear)
                    .accentColor(.clear)
            }
            ForEach(0 ..< done.count, id: \.self) { index in
                Button(action: {
                    
                }) {
                    Done(task: self.done[index])
                }.background(Color.clear)
                    .accentColor(.clear)
            }
        }
    }
}

private struct Waiting: View {
    let task: String
    
    var body: some View {
        VStack {
            Item(string: task)
        }
    }
}

private struct Done: View {
    let task: String
    
    var body: some View {
        HStack {
            Image("check")
            Text(task)
                .font(.caption)
                .lineLimit(1)
            Spacer()
        }
    }
}

private struct Ring: View {
    @Binding var percent: Double
    private let formatter = NumberFormatter()
    
    var body: some View {
        ZStack {
            Path {
                $0.addArc(center: .init(x: 60, y: 60),
                    radius: 55,
                    startAngle: .init(degrees: 0),
                    endAngle: .init(degrees: 360),
                    clockwise: false)
            }.stroke(Color("haze"), lineWidth: 4)
                .opacity(0.2)
            Ringin(percent: percent)
                .stroke(Color("haze"), style: .init(lineWidth: 9, lineCap: .round))
            Text(formatter.string(from: NSNumber(value: percent))!)
                .foregroundColor(.init("haze"))
                .bold()
        }.frame(width: 120, height: 120)
            .padding(.vertical, 10)
            .onAppear {
            self.formatter.numberStyle = .percent
        }
    }
}

private struct Ringin: Shape {
    var percent: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: .init(x: rect.midX, y: rect.midY),
                    radius: 55,
                    startAngle: .init(degrees: -90),
                    endAngle: .init(degrees: (360 * percent) - 90),
                    clockwise: false)
        return path
    }
    
    var animatableData: Double {
        get { percent }
        set { percent = newValue }
    }
}
