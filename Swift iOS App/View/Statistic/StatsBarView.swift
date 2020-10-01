//
//  StatsBarView.swift
//  sporthealth
//
//  Created by Borchers, Alexander on 29.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct StatsBarView: View {
    let barWidth: CGFloat = 10
    let barHeight: CGFloat = 300
    
    let barValue: CGFloat
    let barColor: Color
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Capsule().frame(width: barWidth, height: barHeight)
                .foregroundColor(.primary)
                .opacity(0.2)
            Capsule().frame(width: barWidth, height: barValue * barHeight)
                .foregroundColor(barColor)
        }
    }
}

struct StatsBarView_Previews: PreviewProvider {
    static var previews: some View {
        StatsBarView(barValue: 0.5, barColor: Color.purple)
    }
}
