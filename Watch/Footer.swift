import SwiftUI

struct Footer: View {
    @Binding var name: String
    @State private var deleting = false
    @State private var renaming = false
    let title: LocalizedStringKey
    let placeholder: LocalizedStringKey
    let delete: () -> Void
    let rename: () -> Void
    
    var body: some View {
        HStack {
            Button(action: {
                self.deleting = true
            }) {
                Icon(name: "trash.circle.fill", width: 35, height: 35, color: "haze")
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
                Icon(name: "pencil.circle.fill", width: 35, height: 35, color: "haze")
            }.sheet(isPresented: $renaming) {
                Rename(name: self.$name, placeholder: self.placeholder) {
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
    let placeholder: LocalizedStringKey
    let action: () -> Void
    
    var body: some View {
        TextField(placeholder, text: $name, onCommit: action)
            .background(Color("background")
            .cornerRadius(8))
            .accentColor(.clear)
    }
}
