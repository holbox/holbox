import SwiftUI

struct Delete: View {
    let title: LocalizedStringKey
    var action: () -> Void
    
    var body: some View {
        Button(title, action: action).background(Color("haze")
            .cornerRadius(12))
            .accentColor(.clear)
            .foregroundColor(.black)
            .font(Font.subheadline
                .bold())
            .padding(.horizontal, 20)
    }
}
