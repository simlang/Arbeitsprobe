//
//  SurveyState.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 23.01.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import Foundation

public enum SurveyState {
    case before
    case pause
    case after
    case idle
}

extension SurveyState: Codable {
    enum Key: CodingKey {
        case rawValue
    }
    enum CodingError: Error {
        case unknownValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        switch rawValue {
        case 0:
            self = .before
        case 1:
            self = .pause
        case 2:
            self = .after
        case 3:
            self = .idle
        default:
            throw CodingError.unknownValue
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
        case .before:
            try container.encode(0, forKey: .rawValue)
        case .pause:
            try container.encode(1, forKey: .rawValue)
        case .after:
            try container.encode(2, forKey: .rawValue)
        case .idle:
            try container.encode(3, forKey: .rawValue)
        }
    }
}
