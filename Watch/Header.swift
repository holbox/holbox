import SwiftUI

struct Header: View {
    @Binding var name: String
    
    var body: some View {
        VStack {
            HStack {
                Back()
                Spacer()
            }
            Text(name)
                .font(.caption)
                .foregroundColor(Color("haze"))
                .offset(y: -15)
                .zIndex(-1)
        }.padding(.bottom, -10)
    }
}
