//
//  Survey.swift
//  sporthealth
//
//  Created by Chuying He on 11.01.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

public final class Survey {
    
    public var id: UUID
    public private(set) var questions: [Question]
    public private(set) var moodQuestions: [MoodQuestion]
    public var surveyDeadline: Date
    public var triggerType: SurveyTriggerType
    public var triggerTimestamp: Date
    public var triggerOffset: Int
    public var secondsAvailable: Int
    public var isQueued: Bool
    
    //Survey view related parameters
    @Published public private(set) var currentQuestionID: Question.ID?
    @Published public var surveyState = SurveyState.before
    var questionIndex: Int = 0 // starts with first question
    
    public init(id: UUID = UUID(),
                questions: [Question],
                moodQuestions: [MoodQuestion],
                secondsAvailable: Int,
                triggerType: SurveyTriggerType,
                triggerTimestamp: Date? = nil,
                triggerOffset: Int? = nil,
                surveyDeadline: Date? = nil,
                isQueued: Bool = false) {
        self.id = id
        self.questions = questions
        self.moodQuestions = moodQuestions
        self.secondsAvailable = secondsAvailable
        self.triggerType = triggerType
        self.triggerTimestamp = triggerTimestamp ?? Date()
        self.triggerOffset = triggerOffset ?? 0
        self.surveyDeadline = surveyDeadline ?? (triggerTimestamp ?? Date()).addingTimeInterval(Double(secondsAvailable))
        self.isQueued = isQueued

        if !questions.isEmpty {
            self.currentQuestionID = questions[questionIndex].id
        }
    }
    
    public func getQuestion(by id: Question.ID?) -> Question? {
        for question in questions where question.id == id {
            return question
        }
        return nil
    }
    
    public func getSliderQuestion(by id: Question.ID?) -> SliderQuestion? {
        guard let question = getQuestion(by: id) as? SliderQuestion else {
            return nil
        }
        return question
    }
    
    public func getBinaryQuestion(by id: Question.ID?) -> BinaryQuestion? {
        guard let question = getQuestion(by: id) as? BinaryQuestion else {
            return nil
        }
        return question
    }
    
    public func nextQuestion() {
        if questionIndex < questions.count - 1 {
            questionIndex += 1
            withAnimation {
                currentQuestionID = questions[questionIndex].id
            }
        } else {
            surveyState = .after
        }
    }
    
    public func resetSurvey() {
        questionIndex = 0
        currentQuestionID = questions[questionIndex].id
    }
    
    public func startSurvey() {
        if !questions.isEmpty {
            withAnimation {
                currentQuestionID = questions[questionIndex].id
            }
        }
    }
}
extension Survey: ObservableObject { }

extension Survey: Identifiable {}

extension Survey: Hashable {
    public static func == (lhs: Survey, rhs: Survey) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Survey: Codable {
    enum SurveyCodingKeys: CodingKey {
        case id
        case secondsAvailable
        case questions
        case moodQuestions
        
        case triggerType
        case triggerTimestamp
        case triggerOffset
        
        case surveyDeadline
        case isQueued
    }
    
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SurveyCodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let secondsAvailable = try container.decode(Int.self, forKey: .secondsAvailable)
        let moodQuestions = try container.decode([DecodableMoodQuestion].self, forKey: .moodQuestions).map({ $0.value })
        
        var questions: [Question] = []
        if !moodQuestions.isEmpty {
            questions.append(MoodQuestion(question: "placeholder"))
        }
        try questions.append(contentsOf: container.decode([DecodableQuestion].self, forKey: .questions).map({ $0.value }))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        var surveyDeadline: Date?
        do {
            let surveyDeadlineString = try container.decode(String.self, forKey: .surveyDeadline)
            surveyDeadline = formatter.date(from: surveyDeadlineString)
        } catch { }
        
        let triggerType = try container.decode(SurveyTriggerType.self, forKey: .triggerType)
        var triggerTimestamp: Date?
        var isQueued = false
        var triggerOffset: Int?
        switch triggerType {
        case .now:
            isQueued = true
        case .absolute:
            isQueued = true
            let triggerTimestampString = try container.decode(String.self, forKey: .triggerTimestamp)
            triggerTimestamp = formatter.date(from: triggerTimestampString) ?? Date().addingTimeInterval(30)
        default:
            isQueued = false
            triggerOffset = try container.decode(Int.self, forKey: .triggerOffset)
            do {
                let triggerTimestampString = try container.decode(String.self, forKey: .triggerTimestamp)
                triggerTimestamp = formatter.date(from: triggerTimestampString) ?? Date().addingTimeInterval(30)
            } catch { }
            do { isQueued = try container.decode(Bool.self, forKey: .isQueued) } catch { print("isQueuedDecoding Error") }
        }
        print("IsQUEUEUEUEUEUD? \(isQueued)")

        self.init(id: id,
                  questions: questions,
                  moodQuestions: moodQuestions,
                  secondsAvailable: secondsAvailable,
                  triggerType: triggerType,
                  triggerTimestamp: triggerTimestamp,
                  triggerOffset: triggerOffset,
                  surveyDeadline: surveyDeadline,
                  isQueued: isQueued)
    }

    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SurveyCodingKeys.self)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let triggerTimestampString = formatter.string(from: self.triggerTimestamp)
        let deadlineString = formatter.string(from: self.surveyDeadline)
        
        var questionWithoutMoods = self.questions
        questionWithoutMoods.removeFirst()
        
        try container.encode(self.id, forKey: .id)
        try container.encode(self.secondsAvailable, forKey: .secondsAvailable)
        try container.encode(questionWithoutMoods.map({ DecodableQuestion(question: $0) }), forKey: .questions)
        try container.encode(self.moodQuestions, forKey: .moodQuestions)
        try container.encode(self.triggerType, forKey: .triggerType)
        try container.encode(triggerTimestampString, forKey: .triggerTimestamp)
        try container.encode(self.triggerOffset, forKey: .triggerOffset)
        try container.encode(deadlineString, forKey: .surveyDeadline)
        try container.encode(self.isQueued, forKey: .isQueued)
    }
}

extension Survey: LocalFileStorable {
    static var fileName = "Surveys"
}

extension Survey: CustomStringConvertible {
    public var description: String {
        """
        Survey: id: \(self.id.uuidString)
        questions: \(self.questions)
        moodQuestions: \(self.moodQuestions)
        secondsAvailable: \(self.secondsAvailable)
        triggerType: \(self.triggerType)
        triggerTimestamp: \(self.triggerTimestamp)
        triggerOffset: \(self.triggerOffset)
        isQueued: \(self.isQueued)
        """
    }
}
