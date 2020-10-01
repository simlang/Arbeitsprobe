//
//  CustomProgressBar.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 12.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct CustomProgressBarView: View {
    let currentPage: Int
    let maxPage: Int
    
    var body: some View {
        HStack(alignment: .center, spacing: -0.5) {
            Circle()
                .progressBarCircleViewModifier(index: 0, currentPage: currentPage)
            ForEach(1..<self.maxPage) { index in
                Rectangle()
                    .progressBarRectangleViewModifier(index: index, currentPage: self.currentPage)
                Circle()
                    .progressBarCircleViewModifier(index: index, currentPage: self.currentPage)
            }
        }.padding([.leading, .bottom, .trailing])
    }
}

struct CustomProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomProgressBarView(currentPage: 1, maxPage: 3)
    }
}
