import SwiftUI

struct Card: View {
    @State var card: Int
    @State var list: Int
    let project: Int
    @State private var delete = false
    @State private var deleted = false
    
    var body: some View {
        ScrollView {
            if !deleted {
                Back(title: app.session.name(project, list: list))
                if app.session.content(project, list: list, card: card).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Circle()
                        .foregroundColor(.init("haze"))
                        .opacity(0.5)
                        .frame(width: 15, height: 15)
                } else {
                    Text(app.session.content(project, list: list, card: card))
                        .lineLimit(1)
                        .padding(.horizontal, 20)
                }
                HStack {
                    Button(action: {
                        app.session.move(self.project, list: self.list, card: self.card, destination: self.list - 1, index: 0)
                        self.card = 0
                        withAnimation {
                            self.list -= 1
                        }
                    }) {
                        Image("arrow")
                            .renderingMode(.original)
                            .rotationEffect(.init(degrees: -90))
                            .opacity(list < 1 ? 0.3 : 1)
                    }.background(Color.clear)
                        .accentColor(.clear)
                        .disabled(list < 1)
                    Button(action: {
                        app.session.move(self.project, list: self.list, card: self.card, destination: self.list + 1, index: 0)
                        self.card = 0
                        withAnimation {
                            self.list += 1
                        }
                    }) {
                        Image("arrow")
                            .renderingMode(.original)
                            .rotationEffect(.init(degrees: 90))
                            .opacity(list >= app.session.lists(project) - 1 ? 0.3 : 1)
                    }.background(Color.clear)
                        .accentColor(.clear)
                        .disabled(list >= app.session.lists(project) - 1)
                }.padding(.vertical, 8)
                Button(action: {
                    self.delete = true
                }) {
                    Image("trash")
                        .renderingMode(.original)
                }.background(Color.clear)
                    .accentColor(.clear)
                    .padding(.bottom, 20)
            }
        }.sheet(isPresented: $delete, content: {
            Button(action: {
                self.deleted = true
                app.session.delete(self.project, list: self.list, card: self.card)
                self.delete = false
                WKExtension.shared().rootInterfaceController!.pop()
            }) {
                HStack {
                    Spacer()
                    Image("trash")
                        .renderingMode(.original)
                    Text(.init("Delete.confirm"))
                        .foregroundColor(Color("haze"))
                    Spacer()
                }
            }.background(Color.clear)
                .accentColor(.clear)
                .padding(.bottom, 20)
            
        }).edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
    }
}
