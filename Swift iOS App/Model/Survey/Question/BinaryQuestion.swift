//
//  BinaryQuestion.swift
//  sporthealth
//
//  Created by Jakob on 17.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import Foundation

public class BinaryQuestion: Question {
    let foodOption1: Food
    let foodOption2: Food
    let timingFood1: String
    let timingFood2: String
    
    init(id: UUID? = nil, secondsAvailable: Int, foodOption1: Food, foodOption2: Food, timingFood1: String, timingFood2: String) {
        self.foodOption1 = foodOption1
        self.foodOption2 = foodOption2
        self.timingFood1 = timingFood1
        self.timingFood2 = timingFood2
        
        super.init(id: id, secondsAvailable: secondsAvailable)
    }
    
    private enum CodingKeys: String, CodingKey {
        case food1
        case food2
        case food1Timing
        case food2Timing
    }

    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.foodOption1, forKey: .food1)
        try container.encode(self.foodOption2, forKey: .food2)
        try container.encode(self.timingFood1, forKey: .food1Timing)
        try container.encode(self.timingFood2, forKey: .food2Timing)
    }
}
