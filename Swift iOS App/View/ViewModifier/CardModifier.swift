//
//  CardModifier.swift
//  Diary
//
//  Created by Dominic Henze on 09.10.19.
//  Copyright © 2019 TUM LS1. All rights reserved.
//

import SwiftUI

struct CardModifier: ViewModifier {
    var color: Color
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: 200, maxHeight: 30, alignment: .center)
            .padding(16)
            .background(color)
            .cornerRadius(25)
    }
}

extension View {
    func cardButtonViewModifier(color: Color) -> some View {
        ModifiedContent(content: self, modifier: CardModifier(color: color))
    }
}
