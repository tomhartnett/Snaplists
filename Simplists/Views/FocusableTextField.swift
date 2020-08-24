//
//  FocusableTextField.swift
//  Simplists
//
//  Created by Tom Hartnett on 8/23/20.
//

import SwiftUI

struct FocusableTextField: UIViewRepresentable {
    typealias UIViewType = UITextField

    class Coordinator: NSObject, UITextFieldDelegate {

        var parent: FocusableTextField

        init(_ parent: FocusableTextField) {
            self.parent = parent
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            DispatchQueue.main.async { [self] in
                parent.text = textField.text ?? ""
            }
        }

        func textField(_ textField: UITextField,
                       shouldChangeCharactersIn range: NSRange,
                       replacementString string: String) -> Bool {
            if string == "\n" {
                textField.resignFirstResponder()
                parent.onCommit?()
                return false
            }

            return true
        }
    }

    @Binding var text: String
    var isFirstResponder: Bool = false
    var placeholder = ""
    var onCommit: (() -> Void)?

    init(_ placeholder: String = "",
         text: Binding<String>,
         isFirstResponder: Bool,
         onCommit: (() -> Void)? = nil) {
        self.placeholder = placeholder
        _text = text
        self.isFirstResponder = isFirstResponder
        self.onCommit = onCommit
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.placeholder = placeholder
        textField.returnKeyType = .done
        textField.delegate = context.coordinator
        return textField
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        if isFirstResponder {
            DispatchQueue.main.async {
                uiView.becomeFirstResponder()
            }
        }
    }
}
