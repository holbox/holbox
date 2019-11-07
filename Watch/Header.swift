import SwiftUI

struct Header: View {
    @Binding var name: String
    let back: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Back(action: back)
                Text(name)
                    .font(.caption)
                    .foregroundColor(Color("haze"))
                    .offset(x: -15)
                Spacer()
            }
        }
    }
}
