//
//  PageViewTransitionModifier.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 12.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

extension AnyTransition {
    static var moveSameDirection: AnyTransition {
        let insertion = AnyTransition.move(edge: .trailing)
        let removal = AnyTransition.move(edge: .leading)
        return .asymmetric(insertion: insertion, removal: removal)
    }
    static var moveDifferentDirection: AnyTransition {
        let insertion = AnyTransition.move(edge: .leading)
        let removal = AnyTransition.move(edge: .trailing)
        return .asymmetric(insertion: insertion, removal: removal)
    }
}

struct NavigationViewTransitionModifier: ViewModifier {
    var duration: Double
    
    func body(content: Content) -> some View {
        content
            .animation(.easeInOut(duration: duration))
            .transition(.moveSameDirection)
    }
}

struct NavigationViewReverseTransitionModifier: ViewModifier {
    var duration: Double
    
    func body(content: Content) -> some View {
        content
            .animation(.easeInOut(duration: duration))
            .transition(.moveDifferentDirection)
    }
}

extension View {
    func navigationViewTransitionViewModifier(duration: Double) -> some View {
        ModifiedContent(content: self, modifier: NavigationViewTransitionModifier(duration: duration))
    }
    func navigationViewReverseTransitionViewModifier(duration: Double) -> some View {
        ModifiedContent(content: self, modifier: NavigationViewReverseTransitionModifier(duration: duration))
    }
}
