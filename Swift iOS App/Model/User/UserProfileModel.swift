//
//  UserProfileModel.swift
//  sporthealth
//
//  Created by Borchers, Alexander on 28.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import Foundation
import Combine

public class UserProfileModel {
    public static var updatedStats = false
    
    @Published public private(set) var avoidedFoods: [Food] = []
    @Published public private(set) var avoidableFoods: [Food] = []
    @Published public internal(set) var allergies: [Allergy] = []
    @Published public internal(set) var possibleAllergies: [Allergy] = []
    @Published public private(set) var otherAllergies: String = ""
    
    @Published public private(set) var registeredSince = Date()
    @Published public private(set) var questionsAnswered: Int = 0
    @Published public private(set) var partOfSurveys: Int = 0

    public func setAvoidableFoods(_ avoidableFoods: [Food]) {
        self.avoidableFoods = avoidableFoods
    }
    
    public func addAvoidedFood(_ avoidedFood: Food) {
        self.avoidedFoods.append(avoidedFood)
    }
    
    public func removeAvoidedFood(_ id: Food.ID) {
        self.avoidedFoods.removeAll(where: { $0.id == id })
    }
    
    public func setPossibleAllergies() {
        var currentAllergies: [Allergy] = []
        for food in self.avoidedFoods {
            for allergy in food.possibleAllergies {
                if !currentAllergies.contains(where: { $0.name == allergy.name }) {
                    currentAllergies.append(allergy)
                }
            }
        }
        self.allergies = currentAllergies
        self.possibleAllergies = currentAllergies
    }
    public func getDaysInSurvey() -> String {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: registeredSince, to: Date())
        guard let day = days.day else {
            return "--"
        }
        
        return day.description
    }
    public func setRegisteredSince(_ registeredSince: Date) {
        self.registeredSince = registeredSince
    }
    public func setQuestionsAnswered(_ questionsAnswered: Int) {
        self.questionsAnswered = questionsAnswered
    }
    public func setPartOfSurveys(_ partOfSurveys: Int) {
        self.partOfSurveys = partOfSurveys
    }
    public func resetModel() {
        avoidedFoods = []
        allergies = []
        otherAllergies = ""
        registeredSince = Date()
        questionsAnswered = 0
        partOfSurveys = 0
    }
    
    public func addAllergy(_ allergy: Allergy) {
        self.allergies.append(allergy)
    }
    
    public func addAllergies(_ allergies: [Allergy]) {
        self.allergies.append(contentsOf: allergies)
    }
    
    public func removeAllergy(_ allergy: Allergy) {
        self.allergies.removeAll(where: { $0.id == allergy.id })
    }
    
    func removeDoubleDetectedAllergies() {
        allergies = Array(Set(allergies))
    }
    
    func setOtherAllergies(_ otherAllergies: String) {
        self.otherAllergies = otherAllergies
    }
}

extension UserProfileModel: ObservableObject { }

extension UserProfileModel {
    
    public static var mock: UserProfileModel {
        let all: [Allergy] = [
            Allergy(name: "Erdnüsse", description: "", title: "MockAllergy"),
            Allergy(name: "Schalen-\nfrüchte", description: "", title: "MockAllergy"),
            Allergy(name: "Sesam-\nsamen", description: "", title: "MockAllergy"),
            Allergy(name: "Fisch", description: "", title: "MockAllergy"),
            Allergy(name: "Krebs-\ntiere", description: "", title: "MockAllergy"),
            Allergy(name: "Gluten", description: "", title: "MockAllergy")
        ]
        let saladUrl = URL(string: "https://shiftytum.s3.eu-central-1.amazonaws.com/134778635815786763674")!
        let brownieUrl = URL(string: "https://shiftytum.s3.eu-central-1.amazonaws.com/134778635815786763674")!
        let saladFoodSize1 = FoodSize(id: UUID(), title: "Klein", index: 1, imageUrl: saladUrl)
        let saladFoodSize2 = FoodSize(id: UUID(), title: "Mittel", index: 2, imageUrl: saladUrl)
        let saladFoodSize3 = FoodSize(id: UUID(), title: "Groß", index: 3, imageUrl: saladUrl)
        
        let brownieFoodSize1 = FoodSize(id: UUID(), title: "1 Stück", index: 1, imageUrl: brownieUrl)
        let brownieFoodSize2 = FoodSize(id: UUID(), title: "2 Stücke", index: 2, imageUrl: brownieUrl)
        
        let food1 = Food(id: UUID(),
                         title: "Salat",
                         imageUrl: saladUrl,
                         foodSizes: [saladFoodSize1, saladFoodSize2, saladFoodSize3],
                         possibleAllergies: [all[0], all[1]])
        let food2 = Food(id: UUID(),
                         title: "Salat",
                         imageUrl: saladUrl,
                         foodSizes: [saladFoodSize1, saladFoodSize2, saladFoodSize3],
                         possibleAllergies: [all[0], all[1], all[2]])
        let food3 = Food(id: UUID(), title: "Brownie", imageUrl: brownieUrl, foodSizes: [brownieFoodSize1, brownieFoodSize2])
        let food4 = Food(id: UUID(), title: "Brownie", imageUrl: brownieUrl, foodSizes: [brownieFoodSize1, brownieFoodSize2])
        let food5 = Food(id: UUID(), title: "Brownie", imageUrl: brownieUrl, foodSizes: [brownieFoodSize1, brownieFoodSize2])
        let food6 = Food(id: UUID(), title: "Brownie", imageUrl: brownieUrl, foodSizes: [brownieFoodSize1, brownieFoodSize2])
        let mockedModel = UserProfileModel()
        
        mockedModel.setAvoidableFoods([food1, food2, food3, food4, food5, food6])
        mockedModel.addAllergies(all)
        //mockedModel.possibleAllergies = all
        return mockedModel
    }
}
