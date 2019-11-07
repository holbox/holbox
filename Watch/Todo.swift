import SwiftUI

struct Todo: View {
    @EnvironmentObject var model: Model
    @State private var name = ""
    
    var body: some View {
        ScrollView {
            Header(name: $name) {
                self.model.project = -1
            }
            Button(action: {
                self.model.addCard()
            }) {
                Image("plusbig")
                .renderingMode(.original)
            }.background(Color.clear)
                .accentColor(.clear)
            
            Footer(name: $name, title: .init("Delete.title.\(model.mode.rawValue)"), delete: {
                self.model.delete()
            }) {
                self.model.name(self.name)
            }
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
            .onAppear {
                self.name = self.model.name(self.model.project)
        }
    }
}
