//
//  ContentView.swift
//  SliderQuestion
//
//  Created by Borchers, Alexander on 12.11.19.
//  Copyright © 2019 Borchers, Alexander. All rights reserved.
//

import SwiftUI

struct SliderQuestionView: View {
    @EnvironmentObject private var survey: Survey
    public var question: SliderQuestion
    @State private var amount: Double = 0.0
    
    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Text("Wie viel \(question.food.title) möchtest du essen?")
                .textHeadlineModifier()
            FoodCardUrlView(imageUrl: question.food.foodSizes[Int(amount)].imageUrl)
            VStack {
                HStack(alignment: .center, spacing: 5) {
                    Text(question.food.foodSizes.first?.title ?? "min")
                    Spacer()
                    Text(question.food.foodSizes.last?.title ?? "max")
                }
                //foodSizes.count should be at least 3 and odd, otherwise Slider makes no sense
                Slider(value: $amount, in: 0.0...Double(question.food.foodSizes.count - 1), step: 1.0)
            }

            Text(question.food.title + ": " + question.food.foodSizes[Int(amount)].title)

            Spacer()
            CountdownView(startTime: question.secondsAvailable)
            Spacer()

            Button(action: weiterButtonPressed) {
                ContinueButtonView(text: "Weiter", color: Color("primaryHeadlineColor"))
            }
        }
        .padding()
        .onAppear(perform: initialAmount)
    }
    
    func initialAmount() {
        amount = Double((question.food.foodSizes.count - 1) / 2)
    }
    
    func weiterButtonPressed() {
        let apiRequestManager = ApiRequestManagerWithHandling()
        apiRequestManager.postAnswer(answerId: self.question.food.foodSizes[Int(amount)].id, surveyId: self.survey.id, questionId: self.question.id)
        
        survey.nextQuestion()
    }
}

struct SliderQuestionView_Previews: PreviewProvider {
    static let model = SurveyModel.mock.surveys[0]

    static var previews: some View {
        SliderQuestionView(question: SurveyModel.sliderQuestionMock)
        .environmentObject(model)
    }
}
