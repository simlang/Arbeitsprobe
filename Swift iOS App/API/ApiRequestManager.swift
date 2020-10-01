//
//  ApiRequestManager.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 10.12.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import Foundation
import Squid
import Combine
import Network

class ApiRequestManager {
    let api = ApiService()
    
    let monitor = NWPathMonitor()
    private var internetConnection: Bool
    
    public init() {
        self.internetConnection = false
        registerMonitor()
    }
    
    private func registerMonitor() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.internetConnection = true
            } else {
                self.internetConnection = false
            }
            
            if path.usesInterfaceType(.wifi) {
//                print("WiFi!")
            } else if path.usesInterfaceType(.cellular) {
//                print("Cellular!")
            }
            
            if path.isExpensive {
//                print("expensive 💵")
            }
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
    public func isConnectedToInternet() -> Bool {
        self.internetConnection
    }
    
    //For testing without our api use this request to a public API:
    public func getUsersFromMockApi() -> Response<GetUsersFromMockApiRequest> {
        GetUsersFromMockApiRequest().schedule(with: ApiService(apiUrl: "jsonplaceholder.typicode.com"))
    }
    
    //AvoidableFood
    public func getAvoidableFoods() -> Response<GetAvoidableFoodsRequest> {
        GetAvoidableFoodsRequest().schedule(with: api)
    }
    
    public func postAvoidableFoods(avoidedFoodIds: [UUID]) -> Response<PostAvoidableFoodsRequest> {
        PostAvoidableFoodsRequest(avoidedFoodIds: avoidedFoodIds).schedule(with: api)
    }
    
    public func putAvoidableFood(avoidedFoodId: UUID) -> Response<PutAvoidableFoodRequest> {
        PutAvoidableFoodRequest(avoidedFoodId: avoidedFoodId).schedule(with: api)
    }
    
    public func deleteAvoidableFood(avoidedFoodId: UUID) -> Response<DeleteAvoidableFoodRequest> {
        DeleteAvoidableFoodRequest(avoidedFoodId: avoidedFoodId).schedule(with: api)
    }
    
    //Allergy
    public func getAllergies() -> Response<GetAllergiesRequest> {
        GetAllergiesRequest().schedule(with: api)
    }
    
    public func postAllergies(allergyIds: [UUID]) -> Response<PostAllergiesRequest> {
        PostAllergiesRequest(allergyIds: allergyIds).schedule(with: api)
    }
    
    public func putAllergy(allergyId: UUID) -> Response<PutAllergyRequest> {
        PutAllergyRequest(allergyId: allergyId).schedule(with: api)
    }
    
    public func deleteAllergy(allergyId: UUID) -> Response<DeleteAllergyRequest> {
        DeleteAllergyRequest(allergyId: allergyId).schedule(with: api)
    }
    
    //Survey
    public func getSurveys() -> Response<GetSurveysRequest> {
        GetSurveysRequest().schedule(with: api)
    }
    
    public func getLatestSurveys(latestSurveyId: String) -> Response<GetLatestSurveysRequest> {
        GetLatestSurveysRequest(latestSurveyId: latestSurveyId).schedule(with: api)
    }
    
    //Answer
    public func postAnswer(answerId: UUID, surveyId: UUID, questionId: UUID) -> Response<PostAnswerRequest> {
        PostAnswerRequest(answerId: answerId, surveyId: surveyId, questionId: questionId).schedule(with: api)
    }
    
    public func postMoodAnswer(surveyId: UUID, moodAnswers: [MoodAnswer]) -> Response<PostMoodAnswerRequest> {
        PostMoodAnswerRequest(moodAnswers: moodAnswers, surveyId: surveyId).schedule(with: api)
    }
    
    //Stats
    public func getStats() -> Response<GetStatsRequest> {
        GetStatsRequest().schedule(with: api)
    }
    
    //Profile
    public func postDeviceId(_ deviceId: String) -> Response<PostDeviceIdRequest> {
        PostDeviceIdRequest(deviceId: deviceId).schedule(with: api)
    }
}
