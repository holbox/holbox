import SwiftUI

struct Header: View {
    @Binding var name: String
    let back: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Back(action: back)
                Spacer()
            }
            Text(name)
                .font(.caption)
                .foregroundColor(Color("haze"))
                .offset(y: -20)
                .zIndex(-1)
        }.padding(.bottom, -15)
    }
}
