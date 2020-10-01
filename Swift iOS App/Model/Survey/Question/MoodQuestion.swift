//
//  MoodQuestion.swift
//  sporthealth
//
//  Created by Alex Borchers on 03.01.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import Foundation
import SwiftUI

public class MoodQuestion: Question {
    let question: String
    let leftLabel: String
    let rightLabel: String
    
    init(id: UUID? = nil, question: String, leftLabel: String? = nil, rightLabel: String? = nil) {
        self.question = question
        self.leftLabel = leftLabel ?? ""
        self.rightLabel = rightLabel ?? ""
        super.init(id: id, secondsAvailable: 30)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case question
        case leftLabel
        case rightLabel
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.question, forKey: .question)
        try container.encode(self.leftLabel, forKey: .leftLabel)
        try container.encode(self.rightLabel, forKey: .rightLabel)
    }
}
