//
//  PageViewTransitionModifier.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 12.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        let insertion = AnyTransition.move(edge: .trailing)
            .combined(with: .opacity)
        let removal = AnyTransition.move(edge: .leading)
            .combined(with: .opacity)
        return .asymmetric(insertion: insertion, removal: removal)
    }
}

struct PageViewTransitionModifier: ViewModifier {
    var duration: Double
    
    func body(content: Content) -> some View {
        content
            .animation(.easeInOut(duration: duration))
            .transition(.moveAndFade)
    }
}

extension View {
    func pageViewTransitionViewModifier(duration: Double) -> some View {
        ModifiedContent(content: self, modifier: PageViewTransitionModifier(duration: duration))
    }
}
