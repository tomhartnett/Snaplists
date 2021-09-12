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
            DispatchQueue.main.async {
                self.parent.text = textField.text ?? ""
            }
        }

        func textField(_ textField: UITextField,
                       shouldChangeCharactersIn range: NSRange,
                       replacementString string: String) -> Bool {

            if string == "\n" {
                resignFirstResponderIfNeeded(textField)
                parent.onCommit?()
                return false
            } else {
                let currentText = textField.text ?? ""
                guard let stringRange = Range(range, in: currentText) else { return false }
                let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
                parent.onTextChanged?(updatedText)
            }

            return true
        }

        func resignFirstResponderIfNeeded(_ textField: UITextField) {
            let currentText = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if currentText.isEmpty || !parent.keepFocusUnlessEmpty {
                textField.resignFirstResponder()
            }
        }

        @objc
        func didTapDone() {
            self.parent.textField.resignFirstResponder()
        }
    }

    @Binding var text: String
    var keepFocusUnlessEmpty: Bool = false
    var placeholder = ""
    var onCommit: (() -> Void)?
    var onTextChanged: ((String) -> Void)?

    let textField = UITextField(frame: .zero)

    init(_ placeholder: String = "",
         text: Binding<String>,
         keepFocusUnlessEmpty: Bool,
         onCommit: (() -> Void)? = nil,
         onTextChanged: ((String) -> Void)? = nil) {
        self.placeholder = placeholder
        _text = text
        self.keepFocusUnlessEmpty = keepFocusUnlessEmpty
        self.onCommit = onCommit
        self.onTextChanged = onTextChanged
    }

    func makeUIView(context: Context) -> UITextField {
        textField.placeholder = placeholder
        textField.returnKeyType = .done
        textField.clearButtonMode = .whileEditing
        textField.delegate = context.coordinator
        return textField
    }

    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(self)

        // inputAccessoryView solution
        // https://stackoverflow.com/questions/59114647/swiftui-inputaccesoryview-implementation

        let toolbar = UIToolbar()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace,
                                            target: nil,
                                            action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                         target: coordinator,
                                         action: #selector(coordinator.didTapDone))

        toolbar.items = [flexibleSpace, doneButton]
        toolbar.barStyle = UIBarStyle.default
        toolbar.sizeToFit()

        textField.inputAccessoryView = toolbar

        return coordinator
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
}
