//
//  CountdownView.swift
//  sporthealth
//
//  Created by Borchers, Alexander on 18.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct CountdownView: View {
    @EnvironmentObject private var survey: Survey
    @State var timeLeft = -2
    @State var questionAnswered = false
    @State private var questionId: Question.ID = UUID()
    
    var timer: Timer {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.survey.currentQuestionID == self.questionId {
                self.timeLeft -= 1
            }
            
            if self.questionAnswered {
                timer.invalidate()
            }
            
            if self.timeLeft == 0 && !self.questionAnswered {
                self.survey.nextQuestion()
                timer.invalidate()
            }
            
            if self.survey.currentQuestionID != self.questionId {
                timer.invalidate()
                self.startTime = self.survey.getQuestion(by: self.questionId)?.secondsAvailable ?? 10
                self.startTimer()
            }
        }
    }
    
    @State var startTime: Int
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: getPercentageOfTimeLeft(), to: 1)
                .stroke(Color.gray, lineWidth: 5)
                .frame(maxWidth: 80, maxHeight: 80)
                .rotationEffect(Angle(degrees: -90))
                .opacity(0.3)
                .animation(.default)
            Circle()
                .trim(from: 0, to: getPercentageOfTimeLeft())
                .stroke(Color.blue, lineWidth: 5)
                .frame(maxWidth: 80, maxHeight: 80)
                .rotationEffect(Angle(degrees: -90))
                .animation(.default)
            
            Text(updateTimeLeftLabel())
                .font(.system(size: 22))
        }
        .onAppear(perform: startTimer)
        .onDisappear(perform: { self.questionAnswered = true })
    }
    
    func startTimer() {
        guard let id = survey.currentQuestionID else {
            return
        }
        questionId = id
        timeLeft = startTime
        _ = self.timer
    }
    
    func updateTimeLeftLabel() -> String {
        if timeLeft == 0 {
            return ("0")
        }
        
        return String(timeLeft)
    }
    
    func getPercentageOfTimeLeft() -> CGFloat {
        CGFloat(timeLeft) / CGFloat(startTime)
    }
}

struct CountdownView_Previews: PreviewProvider {
    static let model = SurveyModel.mock.surveys[0]

    static var previews: some View {
        CountdownView(startTime: 10).environmentObject(model)
    }
}
