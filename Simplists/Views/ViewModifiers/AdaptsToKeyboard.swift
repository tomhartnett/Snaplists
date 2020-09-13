//
//  KeyboardObserver.swift
//  Simplists
//
//  Created by Tom Hartnett on 8/16/20.
//

import Combine
import SwiftUI

// https://stackoverflow.com/questions/56491881/move-textfield-up-when-the-keyboard-has-appeared-in-swiftui
// Note, not the accepted answer, but it works. This solution is only necessary on iOS 13, which doesn't avoid the
// keyboard automatically. See version check below.
// TODO: revisit this code with newer Xcode 12 betas and/or when deployment target is raised to iOS 14.
struct AdaptsToKeyboard: ViewModifier {
    @State var currentHeight: CGFloat = 0

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .padding(.bottom, self.currentHeight)
                .animation(.easeOut(duration: 0.16))
                .onAppear(perform: {
                    NotificationCenter.Publisher(center: NotificationCenter.default,
                                                 name: UIResponder.keyboardWillShowNotification)
                        .compactMap { notification in
                            notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect
                    }
                    .map { rect in
                        // FIXME: this is better but not perfect on iOS 14. As this is essentially a no-op and iOS 14
                        // should avoid the keyboard for us, I consider remaining jankiness to be beta issues with 14.
                        if #available(iOS 14.0, *) {
                            return CGFloat.zero
                        } else {
                            return rect.height - geometry.safeAreaInsets.bottom
                        }
                    }
                    .subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))

                    NotificationCenter.Publisher(center: NotificationCenter.default,
                                                 name: UIResponder.keyboardWillHideNotification)
                        .compactMap { _ in
                            CGFloat.zero
                    }
                    .subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))
                })
        }
    }
}
