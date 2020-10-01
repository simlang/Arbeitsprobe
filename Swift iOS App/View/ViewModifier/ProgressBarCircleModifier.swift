//
//  ProgressBarModifier.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 12.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct ProgressBarCircleModifier: ViewModifier {
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
            .frame(width: 15, height: 15)
    }
}

extension View {
    func progressBarCircleViewModifier(index: Int, currentPage: Int) -> some View {
        ModifiedContent(content: self, modifier: ProgressBarCircleModifier(index: index, currentPage: currentPage))
    }
}
