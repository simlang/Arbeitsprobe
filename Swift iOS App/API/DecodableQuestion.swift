//
//  DecodableQuestion.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 12.12.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import Foundation

struct DecodableQuestion: Codable {
    var value: Question
    
    enum DecodableQuestionCodingKeys: String, CodingKey {
        //Question:
        case id
        case type
        case secondsAvailable
        //BinaryQuestion:
        case food1
        case food2
        case food1Timing
        case food2Timing
        //SliderQuestion:
        case food
    }
    
    public init(question: Question) {
        self.value = question
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DecodableQuestionCodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let secondsAvailable = try container.decode(Int.self, forKey: .secondsAvailable)
        let questionType = try container.decode(String.self, forKey: .type)

        switch questionType {
        case "App\\BinaryQuestion":
            let foodOption1 = try container.decode(Food.self, forKey: .food1)
            let foodOption2 = try container.decode(Food.self, forKey: .food2)
            let timingFood1 = try container.decode(String.self, forKey: .food1Timing)
            let timingFood2 = try container.decode(String.self, forKey: .food2Timing)
            self.value = BinaryQuestion(id: id,
                                        secondsAvailable: secondsAvailable,
                                        foodOption1: foodOption1,
                                        foodOption2: foodOption2,
                                        timingFood1: timingFood1,
                                        timingFood2: timingFood2)
        case "App\\SliderQuestion":
            let food = try container.decode(DecodableSliderFood.self, forKey: .food)
            self.value = SliderQuestion(id: id,
                                        secondsAvailable: secondsAvailable,
                                        food: food.value)
        default:
            self.value = Question(id: id,
                                  secondsAvailable: secondsAvailable)
        }
  }
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DecodableQuestionCodingKeys.self)
        try container.encode(self.value.id, forKey: .id)
        try container.encode(self.value.secondsAvailable, forKey: .secondsAvailable)
        
        
        if let binaryQuestion = self.value as? BinaryQuestion {
            try container.encode("App\\BinaryQuestion", forKey: .type)
            try container.encode(binaryQuestion.foodOption1, forKey: .food1)
            try container.encode(binaryQuestion.foodOption2, forKey: .food2)
            try container.encode(binaryQuestion.timingFood1, forKey: .food1Timing)
            try container.encode(binaryQuestion.timingFood2, forKey: .food2Timing)
        } else if let sliderQuestion = self.value as? SliderQuestion {
            try container.encode("App\\SliderQuestion", forKey: .type)
            try container.encode(sliderQuestion.food, forKey: .food)
        } else {
            try container.encode("Error encoding the question", forKey: .type)
        }
    }
}
