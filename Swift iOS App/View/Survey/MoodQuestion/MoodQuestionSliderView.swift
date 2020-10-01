//
//  MoodQuestionSliderView.swift
//  sporthealth
//
//  Created by Alex Borchers on 29.12.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct MoodQuestionSliderView: View {
    @Binding var amount: CGFloat
    var leftLabel: String = ""
    var rightLabel: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(leftLabel.isEmpty ? "Gar nicht" : leftLabel)
                Spacer()
                Text(rightLabel.isEmpty ? "Sehr" : rightLabel)
            }.font(.system(size: 14))
            Slider(value: $amount)
        }
    }
}

struct MoodQuestionSliderView_Previews: PreviewProvider {
    static var previews: some View {
        MoodQuestionSliderView(amount: .constant(0.5))
            .padding()
    }
}
