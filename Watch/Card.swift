import SwiftUI

struct Card: View {
    @ObservedObject var global: Global
    @State var content: String
    var update: (String) -> Void
    
    var body: some View {
        VStack {
            TextField(.init("Card"), text: $content)
            Button(.init("Card.move")) {
                
            }.background(Color("background")
                .cornerRadius(6))
                .foregroundColor(.white)
            Button(.init("Card.done")) {
                self.update(self.content)
            }.background(Color("haze")
                .cornerRadius(6))
                .foregroundColor(.black)
        }.navigationBarBackButtonHidden(true)
    }
}
