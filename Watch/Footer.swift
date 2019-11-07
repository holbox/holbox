import SwiftUI

struct Footer: View {
    @Binding var name: String
    @State private var deleting = false
    @State private var renaming = false
    let title: LocalizedStringKey
    let delete: () -> Void
    let rename: () -> Void
    
    var body: some View {
        HStack {
            Button(action: {
                self.deleting = true
            }) {
                Icon(name: "trash.circle.fill")
            }.sheet(isPresented: $deleting) {
                Delete(title: self.title) {
                    self.deleting = false
                    self.delete()
                }
            }.background(Color.clear)
                .accentColor(.clear)
            Button(action: {
                self.renaming = true
            }) {
                Icon(name: "pencil.circle.fill")
            }.sheet(isPresented: $renaming) {
                Rename(name: self.$name) {
                    self.renaming = false
                    self.rename()
                }
            }.background(Color.clear)
                .accentColor(.clear)
        }.padding(.vertical, 25)
    }
}

private struct Delete: View {
    let title: LocalizedStringKey
    let action: () -> Void
    
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

private struct Rename: View {
    @Binding var name: String
    let action: () -> Void
    
    var body: some View {
        TextField(.init("Project"), text: $name, onCommit: action).background(Color("background")
            .cornerRadius(8))
            .accentColor(.clear)
            .padding(.vertical, 25)
            .offset(y: -10)
    }
}

private struct Icon: View {
    let name: String
    
    var body: some View {
        Image(systemName: name)
            .resizable()
            .foregroundColor(Color("haze"))
            .frame(width: 35, height: 35)
    }
}
