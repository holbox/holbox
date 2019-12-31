import SwiftUI

struct Todo: View {
    @State var waiting: [String]
    @State var done: [(String, String)]
    @State private var percent = Double()
    @State private var display = ""
    let project: Int
    
    var body: some View {
        ScrollView {
            Back(title: app.session.name(project))
            Ring(percent: $percent, display: $display)
            Tasks(waiting: $waiting, done: $done, project: project, refresh: refresh)
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
        waiting = (0 ..< app.session.cards(project, list: 0)).map { app.session.content(project, list: 0, card: $0) }
        done = (0 ..< app.session.cards(project, list: 1)).map {
            (app.session.content(project, list: 1, card: $0),
             (RelativeDateTimeFormatter().localizedString(for: Date(timeIntervalSince1970: TimeInterval(app.session.content(project, list: 2, card: $0))!), relativeTo: .init()))) }
        let count = Double(waiting.count + done.count)
        display = count > 0 ? "\(Int(Double(done.count) / count * 100))" : "0"
        withAnimation(.easeOut(duration: 0.5)) {
            percent = count > 0 ? .init(done.count) / count : 0
        }
    }
}

private struct Tasks: View {
    @Binding var waiting: [String]
    @Binding var done: [(String, String)]
    let project: Int
    let refresh: () -> Void
    
    var body: some View {
        VStack {
            ForEach(0 ..< waiting.count, id: \.self) { index in
                Button(action: {
                    app.session.completed(self.project, index: index)
                    self.refresh()
                }) {
                    HStack {
                        Rectangle()
                            .foregroundColor(.init("haze"))
                            .frame(width: 3, height: 10)
                            .cornerRadius(1.5)
                        Text(self.waiting[index])
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(500)
                            .font(.caption)
                            .foregroundColor(.white)
                        Spacer()
                    }
                }.background(Color.clear)
                    .accentColor(.clear)
            }
            ForEach(0 ..< done.count, id: \.self) { index in
                Button(action: {
                    app.session.restart(self.project, index: index)
                    self.refresh()
                }) {
                    VStack {
                        HStack {
                            Text(self.done[index].1)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(500)
                                .font(.caption)
                                .foregroundColor(.init("haze"))
                            Spacer()
                        }
                        HStack {
                            Text(self.done[index].0)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(500)
                                .font(.caption)
                                .foregroundColor(.white)
                                .opacity(0.5)
                            Spacer()
                        }
                    }
                }.background(Color.clear)
                    .accentColor(.clear)
            }
        }
    }
}

private struct Done: View {
    let task: String
    
    var body: some View {
        HStack {
            Image("check")
                .renderingMode(.template)
                .foregroundColor(Color("haze"))
            if task.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Circle()
                    .foregroundColor(.init("haze"))
                    .opacity(0.5)
                    .frame(width: 10, height: 10)
            } else {
                Text(task)
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundColor(.white)
                    .opacity(0.6)
            }
            Spacer()
        }
    }
}

private struct Ring: View {
    @Binding var percent: Double
    @Binding var display: String
    
    var body: some View {
        ZStack {
            Path {
                $0.addArc(center: .init(x: 60, y: 60),
                    radius: 40,
                    startAngle: .init(degrees: 0),
                    endAngle: .init(degrees: 360),
                    clockwise: false)
            }.fill(Color("haze"))
            Ringin(percent: percent)
                .stroke(Color("haze"), style: .init(lineWidth: 3, lineCap: .round))
            Text("%")
                .foregroundColor(.black)
                .font(.footnote)
                .opacity(0.5)
                .padding(.leading, 25)
            Text(display)
                .foregroundColor(.black)
                .bold()
                .padding(.trailing, 10)
        }.frame(width: 120, height: 120)
            .padding(.init(top: 10, leading: 0, bottom: 30, trailing: 0))
    }
}

private struct Ringin: Shape {
    var percent: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: .init(x: rect.midX, y: rect.midY),
                    radius: 50,
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
