//
//  IntroPictureModifier.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 19.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct IntroTextModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
}

extension View {
    func introTextViewModifier() -> some View {
        ModifiedContent(content: self,
                        modifier: TextHeadlineModifier())
    }
}
