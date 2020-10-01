//
//  SurveyView.swift
//  sporthealth
//
//  Created by Simon Langrieger on 29.11.19.
//  Copyright Â© 2019 TUM. All rights reserved.
//

import SwiftUI
import URLImage

struct SurveyView: View {
    @EnvironmentObject private var surveyModel: SurveyModel
    @State private var surveyActive = false
    @State private var deadline = ""
    @ObservedObject var survey: Survey
    
    let deadlineDescriptionTimer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
        
    var body: some View {
        VStack(spacing: 15) {
            if survey.surveyState == .before ||
                survey.surveyState == .idle {
                headerSurvey
                beforeSurvey
            } else if survey.surveyState == .pause {
                headerSurvey
                pausedSurvey
            } else if survey.surveyState == .after {
                afterSurvey
            }
        }
        .sheet(isPresented: $surveyActive, onDismiss: dismissSurvey) {
            NavigationView {
                QuestionWrapperView().environmentObject(self.survey)
            }
        }
        .onDisappear {
            self.survey.surveyState = .before
        }

        .onAppear {
            self.deadline = self.survey.surveyDeadline.timeIntervalSinceNow.stringFormatted
        }
            
        .onReceive(self.survey.$surveyState, perform: surveyStateUpdate(output:))
    }
    
    private func dismissSurvey() {
        if survey.surveyState != .after {
            self.survey.surveyState = .pause
        }
    }
    
    private func surveyStateUpdate(output: SurveyState) {
        switch output {
        case .before:
            surveyActive = false
        case .pause:
            surveyActive = false
        case .idle:
            surveyActive = true
        case .after:
            surveyActive = false
        }
    }
    
    private var headerSurvey: some View {
        HStack {
            Text("Neue Umfrage verfübar! 🎉")
                .font(Font.system(size: 22, weight: .medium))
                .padding(.horizontal)
            Spacer()
        }
    }
    
    private func surveyDeadline() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E d MMM y, HH:mm"
        return formatter.string(from: survey.surveyDeadline)
    }
    
    private var beforeSurvey: some View {
        VStack(spacing: 15) {
            Spacer()
                .frame(height: 3)
            HStack {
                Text("Du hast noch")
                    .font(Font.system(size: 14, weight: .medium))
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
            }
            HStack {
                Text(deadline)
                    .fontWeight(.bold)
                    .font(.title)
                    .foregroundColor(Color.white)
                    .onReceive(deadlineDescriptionTimer) { _ in
                        let secondsTillCountdown = self.survey.surveyDeadline.timeIntervalSinceNow
                        if secondsTillCountdown <= 0 {
                            self.survey.surveyState = .after
                            self.surveyModel.delete(survey: self.survey.id)
                        }
                        self.deadline = secondsTillCountdown > 0 ? secondsTillCountdown.stringFormatted : TimeInterval(exactly: 0)!.stringFormatted
                    }
            }
            HStack {
                Text("um diese Umfrage zu beantworten")
                    .font(Font.system(size: 14, weight: .medium))
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
            }
            Spacer()
                .frame(height: 3)
            Divider()
            VStack(spacing: 20) {
                Button(action: {
                    self.survey.surveyState = .idle
                }) {
                    ContinueButtonView(text: "Umfrage starten", color: Color("primaryHeadlineColor"))
                }
            }
            Spacer()
                .frame(height: 3)
        }.background(Color("primaryHeadlineColor"))
            .cornerRadius(15)
    }
    
    private var pausedSurvey: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Diese Umfrage beenden?")
                    .font(Font.system(size: 22, weight: .medium))
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                Spacer()
            }.padding()
            Divider()
            HStack {
                Button(action: { self.survey.surveyState = .after }) {
                    ContinueButtonView(text: "Ja", color: Color("primaryHeadlineColor"))
                }
                    .opacity(0.85)
                Button(action: { self.survey.surveyState = .idle }) {
                    ContinueButtonView(text: "Nein", color: Color("primaryHeadlineColor"))
                }
            }.padding()
        }.background(Color("primaryHeadlineColor"))
        .cornerRadius(15)
    }
    
    private var afterSurvey: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Danke für deine Teilnahme!")
                    .font(Font.system(size: 22, weight: .medium))
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
            }.padding()
            Divider()
            HStack {
                Text("Eine neue Umfrage wird bald zur Verfügung stehen.")
                    .font(Font.system(size: 14, weight: .medium))
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
            }.padding()
        }.background(Color("primaryHeadlineColor"))
            .cornerRadius(15)
            .onAppear(perform: {
                self.surveyModel.delete(survey: self.survey.id)
                URLImageService.shared.resetFileCache()
            })
    }
}

struct SurveyView_Previews: PreviewProvider {
    static let model = SurveyModel.mock.surveys[0]
    
    static var previews: some View {
        SurveyView(survey: Survey(questions: [], moodQuestions: [], secondsAvailable: 10, triggerType: .now))
    }
}
