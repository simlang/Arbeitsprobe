//
//  BinaryQuestionView.swift
//  sporthealth
//
//  Created by Jakob on 17.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct BinaryQuestionView: View {
    // MARK: Stored Instance Properties
    /// The model from which to read the question
    @EnvironmentObject private var survey: Survey
    public var question: BinaryQuestion
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Möchtest du lieber ...")
                .textHeadlineModifier()
            
            BinaryOptionView(question: question,
                             foodToDisplay: question.foodOption1,
                             timingToDisplay: question.timingFood1)
                .environmentObject(survey)
            Text("oder")
                .textHeadlineModifier()
            BinaryOptionView(question: question,
                             foodToDisplay: question.foodOption2,
                             timingToDisplay: question.timingFood2)
                .environmentObject(survey)
            CountdownView(startTime: question.secondsAvailable)
                .environmentObject(survey)
        }.padding(.vertical)
    }
}

struct BinaryQuestionView_Previews: PreviewProvider {
    static let model = SurveyModel.mock.surveys[0]

    static var previews: some View {
        BinaryQuestionView(question: SurveyModel.binaryQuestionMock)
            .environmentObject(model)
    }
}
