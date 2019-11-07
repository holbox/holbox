import SwiftUI

struct Todo: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        ScrollView {
            VStack {
                Header(name: model.name(model.project))
//                Columns()
                Footer()
            }
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
    }
}

private struct Header: View {
    @EnvironmentObject var model: Model
    @State var name: String
    
    var body: some View {
        VStack {
            HStack {
                Back {
                    self.model.project = -1
                }
                Spacer()
            }
            TextField(.init("Project"), text: $name) {
                self.model.name(self.name)
            }.background(Color("background")
                .cornerRadius(8))
                .accentColor(.clear)
                .padding(.vertical, 25)
                .offset(y: -10)
            Button(action: {
                self.model.addCard()
            }) {
                Image("plusbig")
                .renderingMode(.original)
            }.background(Color.clear)
                .accentColor(.clear)
        }
    }
}

private struct Footer: View {
    @EnvironmentObject var model: Model
    @State private var deleting = false
    
    var body: some View {
        Button(action: {
            self.deleting = true
        }) {
            Image(systemName: "trash.circle.fill")
                .resizable()
                .foregroundColor(Color("haze"))
                .frame(width: 35, height: 35)
        }.background(Color.clear)
            .accentColor(.clear)
            .padding(.vertical, 20)
            .sheet(isPresented: $deleting) {
                Delete(title: .init("Delete.title.\(self.model.mode.rawValue)")) {
                    self.model.delete()
                    self.deleting = false
                }
            }
    }
}
