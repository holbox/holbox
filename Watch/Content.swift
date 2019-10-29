import SwiftUI

struct Content: View {
    @EnvironmentObject var session: Session
    
    var body: some View {
        Group {
            if session.loading {
                Logo()
            } else if session.creating {
                Add()
            } else if session.more {
                About()
            } else if session.project != nil && session.item != nil {
                Card()
            } else if session.project != nil {
                Board()
            } else {
                Detail()
            }
        }
    }
}

private struct Logo: View {
    var body: some View {
        HStack {
            Spacer()
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
            Spacer()
        }.listRowBackground(Color.clear)
    }
}
