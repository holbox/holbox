import SwiftUI

struct Board: View {
    @EnvironmentObject var session: Session
    @State var columns = 0
    @State var selected: Int?
    let project: Int
    
    var body: some View {
        Circle()
//        List {
//            Header(columns: $columns, selected: $selected, name: global.session.name(project), project: project)
//            ForEach(0 ..< columns, id: \.self) {
//                Column(selected: self.$selected, index: $0, project: self.project)
//            }
//        }.onAppear {
//            self.columns = self.global.session.lists(self.project)
//        }
    }
}
/*
private struct Header: View {
    @EnvironmentObject var global: Global
    @Binding var columns: Int
    @Binding var selected: Int?
    @State var name: String
    let project: Int
    
    var body: some View {
        Section(header:
            TextField(.init("Kanban.project"), text: $name) {
                self.global.session.name(self.project, name: self.name)
            }.background(Color("background")
                .cornerRadius(6))
                .font(Font.body.bold())
        ) {
            Create(columns: $columns, selected: $selected, project: project)
        }
    }
}

private struct Create: View {
    @EnvironmentObject var global: Global
    @Binding var columns: Int
    @Binding var selected: Int?
    let project: Int
    
    var body: some View {
        Button(action: {
            self.global.session.add(self.project, list: 0)
            self.columns = self.global.session.lists(self.project)
            self.selected = 0
        }) {
            HStack {
                Spacer()
                Image("card")
                Spacer()
            }
        }.listRowBackground(Color.clear)
    }
}

private struct Column: View {
    @EnvironmentObject var global: Global
    @Binding var selected: Int?
    let index: Int
    let project: Int
    
    var body: some View {
        Section(header:
            Text(global.session.name(project, list: index))
                .font(Font.headline.bold())
                .foregroundColor(Color("haze")
                    .opacity(0.6))) {
                        ForEach(0 ..< self.global.session.cards(self.project, list: index), id: \.self) {
                            Item(selected: self.$selected, column: self.index, index: $0)
                        }.onDelete {
                            self.global.session.delete(self.project, list: self.index, card: $0.first!)
                            self.global.session = self.global.session
                        }
                        if self.global.session.cards(self.project, list: index) == 0 {
                            Spacer()
                                .listRowBackground(Color.clear)
                        }
        }
    }
}

private struct Item: View {
    @Binding var selected: Int?
    let column: Int
    let index: Int
    
    var body: some View {
        NavigationLink(destination:
            Card(position: .init(column, index))
                .onDisappear {
        //                                    self.global.card = nil
        //                                    self.global.session.content(self.global.project!, list: self.list, card: self.card, content: self.content)
        }, tag: index, selection: $selected) {
                                                Circle()
//                                            if self.global.session.content(self.global.project!, list: self.index, card: card).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                                                Image("empty")
//                                            } else {
//                                                Text(self.global.session.content(self.global.project!, list: self.index, card: card))
//                                                    .fixedSize(horizontal: false, vertical: true)
//                                                    .lineLimit(15)
//                                                    .padding(.vertical, 8)
//                                            }
                                        }.listRowBackground(Color.clear)
    }
}
*/
