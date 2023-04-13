//
//  WatchListView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 8/8/20.
//

import SwiftUI
import SimplistsKit

enum WatchListActiveSheet: Identifiable {
    case freeLimitView
    case newItemView
    case listMenu

    var id: Int {
        hashValue
    }
}

struct WatchListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var storage: SMPStorage
    @EnvironmentObject var storeDataSource: StoreDataSource
    @State var list: SMPList
    @State private var activeSheet: WatchListActiveSheet?

    var isPremiumIAPPurchased: Bool {
        if UserDefaults.simplistsApp.isPremiumIAPPurchased {
            return true
        } else {
            return storage.hasPremiumIAPItem
        }
    }

    var buttonForegroundColor: Color {
        switch list.color {
        case .none, .gray, .red, .orange, .blue, .purple:
            return Color.white
        case .yellow, .green:
            return Color.black
        }
    }

    var buttonBackgroundColor: Color {
        if list.color == .none {
            return Color("ButtonBlue")
        } else {
            return list.color.swiftUIColor
        }
    }

    var body: some View {
        List {
            HStack {
                Button(action: {
                    addNewItem()
                }, label: {
                    Label("Add", systemImage: "plus")
                })
                .padding()
                .buttonStyle(PlainButtonStyle())

                Spacer()

                Button(action: {
                    activeSheet = .listMenu
                }, label: {
                    Image(systemName: "ellipsis.circle")
                })
                .padding()
                .buttonStyle(BorderlessButtonStyle())
            }
            .listRowBackground(EmptyView())
            .font(.title3)
            .foregroundColor(buttonForegroundColor)

            if list.items.isEmpty {
                HStack {
                    Spacer()
                    Text("No items")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.top, 20)
                .listRowBackground(EmptyView())
            } else {
                ForEach(list.items) { item in
                    WatchListItemView(
                        item: item,
                        accentColor: list.color == .none ? Color.white : list.color.swiftUIColor,
                        tapAction: {
                            withAnimation {
                                updateItem(id: item.id, title: item.title, isComplete: !item.isComplete)
                            }
                        }
                    )
                }
                .onDelete(perform: delete)
            }
        }
        .navigationBarTitle(list.title)
        .onReceive(storage.objectWillChange, perform: { _ in
            reload()
        })
        .sheet(item: $activeSheet) { item in
            switch item {
            case .freeLimitView:
                WatchStoreView(freeLimitMessage: FreeLimits.numberOfItems.message)
                    .environmentObject(storeDataSource)

            case .newItemView:
                WatchNewItemView(list: $list)

            case .listMenu:
                WatchListMenuView()
            }
        }
    }

    private func addNewItem() {
        if list.items.count >= FreeLimits.numberOfItems.limit && !isPremiumIAPPurchased {
            activeSheet = .freeLimitView
        } else {
            activeSheet = .newItemView
        }
    }

    private func delete(at offsets: IndexSet) {
        offsets.forEach {
            storage.deleteItem(list.items[$0], list: list)
        }
        withAnimation {
            list.items.remove(atOffsets: offsets)
        }
    }

    private func reload() {
        if let newList = storage.getList(with: list.id) {
            list = newList
        } else {
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func updateItem(id: UUID,
                            title: String,
                            isComplete: Bool) {

        guard let index = list.items.firstIndex(where: { $0.id == id }) else { return }

        list.items.remove(at: index)
        list.items.insert(SMPListItem(id: id, title: title, isComplete: isComplete),
                          at: index)

        list.items.sort(by: { !$0.isComplete && $1.isComplete })

        storage.updateList(list)
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WatchListView(
                list: SMPList(
                    title: "Grocery",
                    items: [
                        SMPListItem(title: "Item 1", isComplete: false),
                        SMPListItem(title: "Item 2", isComplete: true),
                        SMPListItem(title: "Item 3", isComplete: true),
                        SMPListItem(title: "Item 4", isComplete: true)
                    ],
                    color: .orange)
            )
            .environmentObject(SMPStorage())
        }
    }
}
