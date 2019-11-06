import SwiftUI

struct Kanban: View {
    @EnvironmentObject var model: Model
    @Binding var project: Int
    
    var body: some View {
        ScrollView {
            Back {
                self.project = -1
            }
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
    }
}
