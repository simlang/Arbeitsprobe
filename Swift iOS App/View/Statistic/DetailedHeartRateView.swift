//
//  DetailedStatsView.swift
//  sporthealth
//
//  Created by Borchers, Alexander on 29.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct DetailedHeartRateView: View {
    @State var heartRates: [Double]
    @State var selectedHeartRate: Double = -1.0
    
    let heartRateAvg: String
    
    let maxValue: Double = 250.0
    let minValue: Double = 0.0
    let stepSize: Double = 50.0
    
    var body: some View {
        VStack {
            Text("Deine Herzfrequenz im Verlauf deiner letzten Aktivität")
                .textHeadlineModifier()
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(0..<heartRates.count) { index in
                            Button(action: { self.selectedHeartRate = self.heartRates[index] }) {
                                StatsBarView(barValue: CGFloat(self.getNormalizedBarValue(dataPointIndex: index)),
                                             barColor: Color("primaryHeadlineColor"))
                            }
                        }
                    }
                }
                StatsScaleView(minValue: minValue, maxValue: maxValue, step: stepSize)
                    .frame(width: 40, height: 300)
            }
            .padding(.horizontal)
            List {
                LastActivityComponentView(systemNameImage: "waveform.path.ecg",
                                          description: "Puls-Durchschnitt",
                                          value: heartRateAvg,
                                          valueDescription: "bpm",
                                          headerColor: Color.orange,
                                          hasDetails: false)
                if selectedHeartRate > 0 {
                    LastActivityComponentView(
                        systemNameImage: "heart",
                        description: "Ausgewählter Wert",
                        value: "\(Int(selectedHeartRate))",
                        valueDescription: "bpm",
                        headerColor: Color.red,
                        hasDetails: false)
                }
                HStack {
                    Text("Einheit")
                    Spacer()
                    Text("Schläge pro Minute")
                }
            }
        }
        .navigationBarTitle(Text("Herzfrequenz"), displayMode: .inline)
    }
    
    func getNormalizedBarValue(dataPointIndex: Int) -> Double {
        heartRates[dataPointIndex] / maxValue
    }
}

struct DetailedStatsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DetailedHeartRateView(heartRates: [60.0, 70.0, 80.0, 100.0, 150.0, 130.0], heartRateAvg: "100")
            Spacer()
        }
    }
}
