//
//  ProgressBarRectangleModifier.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 12.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct ProgressBarRectangleModifier: ViewModifier {
    let index: Int
    let currentPage: Int
    
    func getForegroundColor() -> Color {
        if index <= currentPage {
            return Color("primaryHeadlineColor")
        }
        return Color.gray
    }
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(getForegroundColor())
            .opacity(0.65)
            .frame(maxWidth: .infinity, maxHeight: 5)
    }
}

extension View {
    func progressBarRectangleViewModifier(index: Int, currentPage: Int) -> some View {
        ModifiedContent(content: self, modifier: ProgressBarRectangleModifier(index: index, currentPage: currentPage))
    }
}
