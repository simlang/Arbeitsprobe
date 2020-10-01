//
//  QuestionSlider.swift
//  SliderQuestion
//
//  Created by Borchers, Alexander on 12.11.19.
//  Copyright © 2019 Borchers, Alexander. All rights reserved.
//

import Foundation

public class SliderQuestion: Question {
    let food: Food
    
    init(id: UUID? = nil, secondsAvailable: Int, food: Food) {
        self.food = food
        
        super.init(id: id, secondsAvailable: secondsAvailable)
    }
    
    public func setAnswer() {
        //print("answer")
    }
    
    private enum CodingKeys: String, CodingKey {
        case food
    }

    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.food, forKey: .food)
    }
}
