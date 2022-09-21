//
//  RenameListView.swift
//  Simplists
//
//  Created by Tom Hartnett on 9/5/20.
//

import SwiftUI

struct EditListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var id: String
    @Binding var title: String
    @State private var selectedColor: ListColor = .none

    var doneAction: ((String, String) -> Void)?

    var body: some View {
        NavigationView {
            Form {
                Section {
                    FocusableTextField("Enter name...".localize(),
                                       text: $title,
                                       keepFocusUnlessEmpty: false,
                                       onCommit: saveChanges)
                }

                Section {
                    ForEach(ListColor.allCases, id: \.self) { color in
                        HStack(spacing: 20) {
                            Image(systemName: "app.fill")
                                .foregroundColor(color.swiftUIColor)

                            Text(color.title)

                            Spacer()

                            if selectedColor == color {
                                Image(systemName: "checkmark")
                            } else {
                                EmptyView()
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedColor = color
                        }
                    }
                }
            }
            .navigationBarItems(
                leading: Button(action: {
                    dismiss()
                }, label: {
                    Text("Cancel")
                        .fontWeight(.regular)
                }),
                trailing: Button(action: {
                    saveChanges()
                }, label: {
                    Text("Done")
                        .fontWeight(.semibold)
                })
                .disabled(title.isEmpty)
            )
            .navigationBarTitle("Edit List", displayMode: .inline)
        }
    }

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    private func saveChanges() {
        guard !title.isEmpty else { return }

        doneAction?(id, title)
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EditListView(id: .constant("12345"), title: .constant("Weekend TODOs"))
        }
    }
}

enum ListColor: CaseIterable, Hashable {
    case none
    case red
    case orange
    case yellow
    case green
    case blue
    case purple
    case gray

    var swiftUIColor: Color {
        switch self {
        case .none:
            return .clear
        case .gray:
            return .gray
        case .red:
            return .red
        case .orange:
            return .orange
        case .yellow:
            return .yellow
        case .green:
            return .green
        case .blue:
            return .blue
        case .purple:
            return .purple
        }
    }

    var title: String {
        switch self {
        case .none:
            return "None"
        case .gray:
            return "Gray"
        case .red:
            return "Red"
        case .orange:
            return "Orange"
        case .yellow:
            return "Yellow"
        case .green:
            return "Green"
        case .blue:
            return "Blue"
        case .purple:
            return "Purple"
        }
    }
}
