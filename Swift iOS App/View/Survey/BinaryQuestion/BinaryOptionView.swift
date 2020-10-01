//
//  BinaryOptionView.swift
//  sporthealth
//
//  Created by Jakob on 19.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct BinaryOptionView: View {
    // MARK: Stored Instance Properties
    /// The model from which to read the question
    @EnvironmentObject private var survey: Survey
    @EnvironmentObject private var surveyModel: SurveyModel
    /// The question ID
    public var question: BinaryQuestion
    let foodToDisplay: Food
    let timingToDisplay: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            HStack(alignment: .center) {
                Text(foodToDisplay.title)
                    .font(.system(size: 20))
                Image(systemName: "arrow.right")
                Text(timingToDisplay)
                    .font(.system(size: 20))
                Spacer()
            }
            Button(action: {
                self.onImageClick(food: self.foodToDisplay)
            }) {
                FoodCardUrlView(imageUrl: foodToDisplay.imageUrl)
            }
        }.padding(7)
    }
}

extension BinaryOptionView {
    func onImageClick(food: Food) {
        let apiRequestManager = ApiRequestManagerWithHandling()
        apiRequestManager.postAnswer(answerId: self.foodToDisplay.id, surveyId: self.survey.id, questionId: self.question.id)
        
        self.survey.nextQuestion()
    }
}

struct BinaryOptionView_Previews: PreviewProvider {
    static var model = SurveyModel.mock.surveys[0]
    
    static var previews: some View {
        BinaryOptionView(question: SurveyModel.binaryQuestionMock,
                         foodToDisplay: SurveyModel.binaryQuestionMock.foodOption1,
                         timingToDisplay: SurveyModel.binaryQuestionMock.timingFood1)
            .environmentObject(model)
    }
}
