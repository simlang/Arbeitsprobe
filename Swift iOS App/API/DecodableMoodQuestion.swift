//
//  DecodableQuestion.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 12.12.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import Foundation

struct DecodableMoodQuestion: Codable {
    var value: MoodQuestion
    
    enum MoodQuestionCodingKeys: String, CodingKey {
        //Question:
        case id
        case question
        case leftLabel
        case rightLabel
    }
    
    public init(moodQuestion: MoodQuestion) {
        self.value = moodQuestion
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MoodQuestionCodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let question = try container.decode(String.self, forKey: .question)
        let leftLabel = try container.decode(String.self, forKey: .leftLabel)
        let rightLabel = try container.decode(String.self, forKey: .rightLabel)

        self.value = MoodQuestion(id: id,
                                  question: question,
                                  leftLabel: leftLabel,
                                  rightLabel: rightLabel)
  }
}
