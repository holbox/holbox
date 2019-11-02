import SwiftUI

struct Content: View {
    @EnvironmentObject var session: Session
    
    var body: some View {
        ZStack {
            Logo()
            if !session.loading {
                Detail()
                if session.project == nil {
                    if session.more {
                        About()
                    }
                    if session.creating {
                        Add()
                    }
                } else {
                    Board()
                    if session.item != nil {
                        Card()
                    }
                }
            }
        }.navigationBarHidden(true)
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
