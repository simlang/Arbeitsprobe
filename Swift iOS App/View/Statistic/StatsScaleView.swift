//
//  StatsScaleView.swift
//  sporthealth
//
//  Created by Alex Borchers on 05.01.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI

struct StatsScaleView: View {
    let minValue: Double
    let maxValue: Double
    let step: Double
    
    var body: some View {
        HStack {
            Divider()
            VStack {
                Text(String(Int(maxValue)))
                Spacer()
                ForEach(1..<getStepCounter()) { index in
                    Text(self.getStepValue(index))
                    Spacer()
                }
                Text(String(Int(minValue)))
            }
        }
    }
    
    func getStepCounter() -> Int {
        Int(maxValue / step)
    }
    
    func getStepValue(_ index: Int) -> String {
        String(Int(self.maxValue - self.step * Double(index)))
    }
}

struct StatsScaleView_Previews: PreviewProvider {
    static var previews: some View {
        StatsScaleView(minValue: 0, maxValue: 250, step: 50)
    }
}
