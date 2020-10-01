//
//  AdaptsToSoftwareKeyboard.swift
//  sporthealth
//
//  Created by Jakob on 30.01.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI
import Combine

//by https://gist.github.com/scottmatthewman/722987c9ad40f852e2b6a185f390f88d
struct AdaptsToSoftwareKeyboard: ViewModifier {
    @State var currentHeight: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, currentHeight)
            .edgesIgnoringSafeArea(.bottom)
            .onAppear(perform: subscribeToKeyboardEvents)
    }
    
    private func subscribeToKeyboardEvents() {
        NotificationCenter.Publisher(
            center: NotificationCenter.default,
            name: UIResponder.keyboardWillShowNotification
        )
        .compactMap { notification in
            notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect
        }
        .map { rect in
            rect.height
        }
        .subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))
        
        NotificationCenter.Publisher(
            center: NotificationCenter.default,
            name: UIResponder.keyboardWillHideNotification
        )
        .compactMap { _ in
            CGFloat.zero
        }
        .subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))
    }
}
//struct AdaptsToSoftwareKeyboard_Previews: PreviewProvider {
//    static var previews: some View {
//        AdaptsToSoftwareKeyboard()
//    }
//}
