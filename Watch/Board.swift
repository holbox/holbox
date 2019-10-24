import SwiftUI

struct Board: View {
    @EnvironmentObject var global: Global
    
    var body: some View {
        List {
            Section(header:
                VStack {
                    Text(self.global.session.name(self.global.project!))
                }
            ) { EmptyView() }
        }
    }
}
