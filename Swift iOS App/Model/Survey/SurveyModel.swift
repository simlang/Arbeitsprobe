//
//  Model.swift
//  SliderQuestion
//
//  Created by Borchers, Alexander on 12.11.19.
//  Copyright © 2019 Borchers, Alexander. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

public class SurveyModel {
    
    let notificationManager = AppNotification()
    
    @Published public private(set) var surveys: [Survey] {
        didSet {
            surveys.saveToFile(path: "Surveys")
        }
    }
    
    init(surveys: [Survey]? = nil, unqueuedSurveys: [Survey]? = nil) {
        self.surveys = surveys ?? Survey.loadFromFile(from: "Surveys")
    }
    
    public func addNewSurveys(_ surveys: [Survey]) {
        for survey in surveys {
            if !self.surveys.contains(survey) {
                self.save(survey)
            }
        }
    }
    public func triggerSurveysSave() {
        surveys.saveToFile(path: "Surveys")
    }
    public func getSurvey(by id: Survey.ID?) -> Survey? {
        surveys.first(where: { $0.id == id })
    }
    public func delete(survey id: Survey.ID) {
        surveys.removeAll(where: { $0.id == id })
    }
    public func delete(at offset: IndexSet) {
        surveys.remove(atOffsets: offset)
    }
    public func save(_ survey: Survey) {
        delete(survey: survey.id)
        surveys.append(survey)
    }
    public func resetModel() {
        surveys = []
    }
    
    public func queueUnqueuedSurveys(firstActivity: Activity? = nil) {
        for survey in surveys {
            if !survey.isQueued, let activity = firstActivity {
                switch survey.triggerType {
                case .relativeBeforeActivity:
                    survey.triggerTimestamp = activity.startDate.addingTimeInterval(Double(0 - survey.triggerOffset * 60))
                    survey.surveyDeadline = survey.triggerTimestamp.addingTimeInterval(Double(survey.secondsAvailable))
                    self.notificationManager.queueLocalNotification(date: survey.triggerTimestamp)
                    survey.isQueued = true
                    self.triggerSurveysSave()
                case .relativeAfterActivity:
                    survey.triggerTimestamp = activity.endDate.addingTimeInterval(Double(survey.triggerOffset * 60))
                    survey.surveyDeadline = survey.triggerTimestamp.addingTimeInterval(Double(survey.secondsAvailable))
                    self.notificationManager.queueLocalNotification(date: survey.triggerTimestamp)
                    survey.isQueued = true
                    self.triggerSurveysSave()
                default:
                    break
                }
            }
        }
    }
}

extension SurveyModel: ObservableObject { }

extension SurveyModel {
    public static var binaryQuestionMock: BinaryQuestion {
        let saladUrl = URL(string: "https://shiftytum.s3.eu-central-1.amazonaws.com/134778635815786763674")!
        let brownieUrl = URL(string: "https://shiftytum.s3.eu-central-1.amazonaws.com/134778635815786763674")!
        let food1 = Food(id: UUID(), title: "Gemischtes Obst", imageUrl: saladUrl, foodSizes: [], possibleAllergies: [])
        let food2 = Food(id: UUID(), title: "Brownie", imageUrl: brownieUrl, foodSizes: [], possibleAllergies: [])
        return BinaryQuestion(secondsAvailable: 10, foodOption1: food1, foodOption2: food2, timingFood1: "Jetzt", timingFood2: "In 4 Stunden")
    }
    
    public static var sliderQuestionMock: SliderQuestion {
        let saladUrl = URL(string: "https://shiftytum.s3.eu-central-1.amazonaws.com/134778635815786763674")!
        let brownieUrl = URL(string: "https://shiftytum.s3.eu-central-1.amazonaws.com/134778635815786763674")!
        let foodSize1 = FoodSize(id: UUID(), title: "Klein", index: 0, imageUrl: saladUrl)
        let foodSize2 = FoodSize(id: UUID(), title: "mittel", index: 1, imageUrl: brownieUrl)
        let foodSize3 = FoodSize(id: UUID(), title: "groß", index: 0, imageUrl: saladUrl)
        let sliderFood = Food(id: UUID(), title: "Pizza", imageUrl: brownieUrl, foodSizes: [foodSize1, foodSize2, foodSize3])
        return SliderQuestion(secondsAvailable: 10,
                              food: sliderFood)
    }
    
    public static var moodQuestionsMock: [MoodQuestion] {
        let moodQuestion1 = "Wie hungrig bist du?"
        let moodQuestion2 = "Wie durstig bist du?"
        let moodQuestion3 = "Wie satt bist du?"
        let moodQuestion4 = "Wie übel ist dir?"
        let moodQuestion5 = "Wie gestresst bist du?"
        return [
                MoodQuestion(question: moodQuestion1),
                MoodQuestion(question: moodQuestion2),
                MoodQuestion(question: moodQuestion3),
                MoodQuestion(question: moodQuestion4),
                MoodQuestion(question: moodQuestion5)
        ]
    }
        
    public static var mock: SurveyModel {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        //absolute
        let surveyTriggerValue1 = Date().daysAfter(amount: 1) ?? Date()
        let survey1 = Survey(questions: [binaryQuestionMock, binaryQuestionMock, binaryQuestionMock],
                             moodQuestions: moodQuestionsMock,
                             secondsAvailable: 1800,
                             triggerType: .absolute,
                             triggerTimestamp: surveyTriggerValue1)
        
        // relative to activity
        let survey2 = Survey(questions: [sliderQuestionMock, sliderQuestionMock, sliderQuestionMock],
                             moodQuestions: moodQuestionsMock,
                             secondsAvailable: 1800,
                             triggerType: .relativeAfterActivity,
                             triggerOffset: 1800)
        
        let survey3 = Survey(questions: [sliderQuestionMock, binaryQuestionMock, sliderQuestionMock, binaryQuestionMock],
                             moodQuestions: moodQuestionsMock,
                             secondsAvailable: 1800,
                             triggerType: .relativeBeforeActivity,
                             triggerOffset: 300)
        
        let mock = SurveyModel(surveys: [survey1, survey2, survey3])
        return mock
    }
}
