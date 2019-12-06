import SwiftUI

struct Notes: View {
    let project: Int
    
    var body: some View {
        ScrollView {
            Back(title: app.session.name(project))
            Text(app.session.content(project, list: 0, card: 0))
                .padding(.bottom, 20)
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
    }
}
