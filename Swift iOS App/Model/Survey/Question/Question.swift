//
//  Question.swift
//  SliderQuestion
//
//  Created by Borchers, Alexander on 12.11.19.
//  Copyright © 2019 Borchers, Alexander. All rights reserved.
//

import Foundation

public class Question {
    public var id: UUID
    let secondsAvailable: Int
    
    public init(id: UUID? = nil, secondsAvailable: Int) {
        self.id = id ?? UUID()
        self.secondsAvailable = secondsAvailable
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case secondsAvailable
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(secondsAvailable, forKey: .secondsAvailable)
    }
}

extension Question: Identifiable { }

extension Question: Encodable {}
