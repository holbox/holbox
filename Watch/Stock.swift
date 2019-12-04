/*import SwiftUI

struct Stock: View {
    @EnvironmentObject var model: Model
    @Binding var show: Bool
    let index: Int?
    @State private var emoji = ""
    @State private var label = ""
    @State private var first = true
    
    var body: some View {
        ScrollView {
            VStack {
                Emoji(emoji: $emoji)
                Label(label: $label)
                if index == nil {
                    New(show: $show, emoji: $emoji, label: $label)
                } else {
                    Edit(show: $show, emoji: $emoji, label: $label, index: index!) {
                        self.model.delete(self.index!)
                        self.show = false
                    }
                }
            }
        }.onAppear {
            if self.first {
                self.first = false
                if let index = self.index {
                    self.emoji = self.model.product(index).0
                    self.label = self.model.product(index).1
                } else {
                    self.emoji = NSLocalizedString("Stock.add.emoji", comment: "")
                    self.label = NSLocalizedString("Stock.add.label", comment: "")
                }
            }
        }
    }
}

private struct Emoji: View {
    @EnvironmentObject var model: Model
    @Binding var emoji: String
    
    var body: some View {
        TextField(.init("Product.emoji"), text: $emoji) {
            if self.emoji.mark({ mode, _ in mode }).first(where: { $0 != .emoji }) != nil {
                self.emoji = ""
            } else if self.emoji.count > 1 {
                self.emoji = .init(self.emoji.suffix(1))
            }
        }.background(Color("background")
            .cornerRadius(8))
            .accentColor(.clear)
    }
}

private struct Label: View {
    @EnvironmentObject var model: Model
    @Binding var label: String
    
    var body: some View {
        TextField(.init("Product.description"), text: $label)
            .background(Color("background")
            .cornerRadius(8))
            .accentColor(.clear)
    }
}

private struct New: View {
    @EnvironmentObject var model: Model
    @Binding var show: Bool
    @Binding var emoji: String
    @Binding var label: String
    
    var body: some View {
        Button(.init("Stock.add.done")) {
            self.show = false
            withAnimation(.linear(duration: 0.8)) {
                self.model.addProduct(self.emoji, description: self.label)
            }
        }.background(Color("haze")
            .cornerRadius(12))
            .accentColor(.clear)
            .font(Font.subheadline
                .bold())
            .foregroundColor(.black)
            .padding(.horizontal, 20)
    }
}

private struct Edit: View {
    @EnvironmentObject var model: Model
    @Binding var show: Bool
    @Binding var emoji: String
    @Binding var label: String
    let index: Int
    @State private var deleting = false
    var delete: () -> Void
    
    var body: some View {
        VStack {
            Button(.init("Stock.edit.done")) {
                self.model.product(self.index, emoji: self.emoji, description: self.label)
                self.show = false
            }.background(Color("haze")
                .cornerRadius(12))
                .accentColor(.clear)
                .font(Font.subheadline
                    .bold())
                .foregroundColor(.black)
                .padding(.horizontal, 20)
            Button(.init("Stock.delete")) {
                self.deleting = true
            }.sheet(isPresented: $deleting) {
                Delete {
                    self.deleting = false
                    self.delete()
                }.environmentObject(self.model)
            }.background(Color("background")
                .cornerRadius(12))
                .accentColor(.clear)
                .font(Font.subheadline
                    .bold())
                .foregroundColor(Color("haze"))
                .padding(.horizontal, 20)
        }
    }
}

private struct Delete: View {
    @EnvironmentObject var model: Model
    var action: () -> Void
    
    var body: some View {
        Button(.init("Delete.title.card.\(model.mode.rawValue)"), action: action)
            .background(Color("haze")
            .cornerRadius(12))
            .accentColor(.clear)
            .foregroundColor(.black)
            .font(Font.subheadline
                .bold())
            .padding(.horizontal, 20)
    }
}
*/
