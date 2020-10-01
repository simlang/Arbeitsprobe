//
//  UserDefaultsPublisher.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 05.12.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import Foundation

class UserDefaultsPublisher: ObservableObject {
    
    @Published var introDone: Bool = UserDefaults.standard.bool(forKey: "introDone") {
        didSet {
            UserDefaults.standard.set(self.introDone, forKey: "introDone")
        }
    }
    @Published var apiKey: String = UserDefaults.standard.string(forKey: "apiKey") ?? "" {
        didSet {
            UserDefaults.standard.set(self.apiKey, forKey: "apiKey")
        }
    }
    @Published var latestSurveyId: String = UserDefaults.standard.string(forKey: "latestSurveyId") ?? "" {
        didSet {
            UserDefaults.standard.set(self.latestSurveyId, forKey: "latestSurveyId")
        }
    }
}
