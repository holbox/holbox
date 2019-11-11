import SwiftUI

struct Icon: View {
    let name: String
    let width: CGFloat
    let height: CGFloat
    let color: String
    
    var body: some View {
        Image(systemName: name)
            .resizable()
            .foregroundColor(Color(color))
            .frame(width: width, height: height)
    }
}
