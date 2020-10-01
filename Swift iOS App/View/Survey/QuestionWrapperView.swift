//
//  QuestionWrapperView.swift
//  sporthealth
//
//  Created by Simon Langrieger on 27.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct QuestionWrapperView: View {
    @EnvironmentObject private var survey: Survey
    @State var moodQuestionsAnswered: Bool = false
    
    var body: some View {
        survey.getQuestion(by: survey.currentQuestionID).map { question in
            VStack {
                Spacer()
                questionView(question)
                    .navigationBarTitle("Umfrage", displayMode: .inline)
            }
        }
    }
        
    func questionView(_ question: Question) -> AnyView {
        if let question = question as? BinaryQuestion {
            return AnyView(BinaryQuestionView(question: question)
                .environmentObject(survey)
                .transition(.moveAndFade))
        } else if let question = question as? SliderQuestion {
            return AnyView(SliderQuestionView(question: question)
                .environmentObject(survey)
                .transition(.moveAndFade))
        } else if question is MoodQuestion {
            return AnyView(MoodQuestionView(amounts: Array(repeating: 0.5, count: survey.moodQuestions.count))
                .environmentObject(survey)
                .transition(.moveAndFade))
        } else {
            return AnyView(Text("Error loading question"))
        }
    }
}

struct QuestionWrapperView_Previews: PreviewProvider {
    static let model = SurveyModel.mock.surveys[0]
    
    static var previews: some View {
        QuestionWrapperView().environmentObject(model)
    }
}
