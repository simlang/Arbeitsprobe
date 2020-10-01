//
//  IntroTextHeadlineModifier.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 14.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct TextHeadlineModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(Font.system(size: 26, weight: .bold))
            .foregroundColor(Color("primaryHeadlineColor"))
            .multilineTextAlignment(.center)
    }
}

extension View {
    func textHeadlineModifier() -> some View {
        ModifiedContent(content: self,
                        modifier: TextHeadlineModifier())
    }
}
