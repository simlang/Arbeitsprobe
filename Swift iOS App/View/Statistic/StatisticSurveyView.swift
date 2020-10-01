//
//  StatisticSurveyView.swift
//  sporthealth
//
//  Created by Borchers, Alexander on 28.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct StatisticSurveyView: View {
    let value: String
    let description: String
    
    var body: some View {
        HStack {
            Text(value)
                .fontWeight(.bold)
                .font(.title)
                .foregroundColor(Color("primaryHeadlineColor"))
            HStack {
                Text(description)
                    .font(Font.system(size: 16))
            }
        }
    }
}

struct StatisticSurveyView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticSurveyView(value: "50", description: "Beantwortete Fragen")
    }
}
