//
//  MoodQuestionView.swift
//  sporthealth
//
//  Created by Alex Borchers on 29.12.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct MoodQuestionView: View {
    @EnvironmentObject private var survey: Survey
    @State var amounts: [CGFloat]
    
    @State private var askedUserToInputSth = false
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            Text("Wie fühlst du dich gerade?").textHeadlineModifier()
            Form {
                ForEach(0..<self.survey.moodQuestions.count) { index in
                    Section(header: Text(self.survey.moodQuestions[index].question).font(.system(size: 18))) {
                        MoodQuestionSliderView(amount: self.$amounts[index],
                                               leftLabel: self.survey.moodQuestions[index].leftLabel,
                                               rightLabel: self.survey.moodQuestions[index].rightLabel)
                    }
                }
            }
            Button(action: finishMoodQuestions) {
                ContinueButtonView(text: "Weiter")
            }.alert(isPresented: $showAlert) {
                Alert(title: Text("Keine Eingabe erkannt"),
                      message: Text("Willst du an deiner Auswahl noch etwas korrigieren?"),
                      primaryButton: .default(Text("Nein"), action: {
                        self.askedUserToInputSth = true
                        self.finishMoodQuestions()
                      }), secondaryButton: .default(Text("Ja"), action: {
                        self.askedUserToInputSth = true
                      }))
            }
        }.padding(.vertical)
    }
    
    private func finishMoodQuestions() {
        if onlyDefaultValues() && !askedUserToInputSth {
            showAlert = true
            return
        }
        
        var moodsAnswers: [MoodAnswer] = []
        for (index, amount) in amounts.enumerated() {
            moodsAnswers.append(MoodAnswer(id: self.survey.moodQuestions[index].id, value: Double(amount)))
        }
        let apiRequestManager = ApiRequestManagerWithHandling()
        apiRequestManager.postMoodAnswer(surveyId: self.survey.id, moodAnswers: moodsAnswers)
        
        self.survey.nextQuestion()
    }
    
    private func onlyDefaultValues() -> Bool {
        for amount in amounts where amount != 0.5 {
            return false
        }
        
        return true
    }
}

struct MoodQuestionView_Previews: PreviewProvider {
    static let model = SurveyModel.mock.surveys[0]

    static var previews: some View {
        MoodQuestionView(amounts: Array(repeating: 0.5,
                                        count: SurveyModel.moodQuestionsMock.count))
            .environmentObject(model)
    }
}
