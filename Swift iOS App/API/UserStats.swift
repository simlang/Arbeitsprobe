//
//  UserStats.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 11.12.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import Foundation

struct UserStats {
    var registeredSince: Date
    var questionsAnswered: Int
    var partOfSurveys: Int
}

extension UserStats: Decodable {
    enum UserStatsCodingKeys: String, CodingKey {
        case registeredSince
        case questionsAnswered
        case partOfSurveys
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: UserStatsCodingKeys.self)
        let registeredSince: String = try container.decode(String.self, forKey: .registeredSince)
        let questionsAnswered = try container.decode(Int.self, forKey: .questionsAnswered)
        let partOfSurveys = try container.decode(Int.self, forKey: .partOfSurveys)
        
        let ymd = registeredSince.split(separator: "T", maxSplits: 1, omittingEmptySubsequences: true)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-ddZ"
        dateFormatter.locale = Locale(identifier: "en_US")
        let date = dateFormatter.date(from: "\(ymd[0])Z")
        if date == nil {
            print("date is nil")
        }

        let registeredDate = date ?? Date()
        print("Participant is registered since: \(registeredDate)")
        self.init(registeredSince: registeredDate,
                  questionsAnswered: questionsAnswered,
                  partOfSurveys: partOfSurveys)
    }
}
