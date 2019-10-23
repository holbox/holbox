import SwiftUI

struct Add: View {
    @EnvironmentObject var global: Global
    var add: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                HStack {
                    Spacer()
                    
                    Image("new")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                    
                    Spacer()
                }
                
                Text(.init("Add.title.\(global.mode.rawValue)")).font(.headline)
                
                Text(.init("Add.subtitle.other"))
                
                Text("\(global.session.available)")
                    .font(.largeTitle)
                
                if global.session.available > 0 {
                    Button(action: add) {
                        Text(.init("Add.title.\(self.global.mode.rawValue)"))
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                    }
                    .background(Color("haze"))
                    .cornerRadius(6, antialiased: true)
                    .padding(.horizontal, 20)
                } else {
                    Text(.init("Add.other"))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
