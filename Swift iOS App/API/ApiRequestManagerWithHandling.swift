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
import UIKit

class ApiRequestManagerWithHandling {
    let api = ApiService()
    private var cancellableSet: Set<AnyCancellable> = []
    private var activityModel: ActivityModel?
    private var userProfileModel: UserProfileModel?
    private var surveyModel: SurveyModel?
    private var userDefaultsPublisher: UserDefaultsPublisher?
    
    let monitor = NWPathMonitor()
    private var internetConnection: Bool
    
    public init(activityModel: ActivityModel? = nil,
                userProfileModel: UserProfileModel? = nil,
                surveyModel: SurveyModel? = nil,
                userDefaultsPublisher: UserDefaultsPublisher? = nil) {
        self.activityModel = activityModel
        self.userProfileModel = userProfileModel
        self.surveyModel = surveyModel
        self.userDefaultsPublisher = userDefaultsPublisher
        
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
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
    public func isConnectedToInternet() -> Bool {
        self.internetConnection
    }
    
    //For testing without our api use this request to a public API:
    public func getUsersFromMockApi() {
        let response = GetUsersFromMockApiRequest().schedule(with: ApiService(apiUrl: "jsonplaceholder.typicode.com"))
        cancellableSet.insert(response.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("MockApiCall failed due to: \(error)")
            case .finished:
                print("MockApiCall finished.")
            }
        }) { result in
            print("Received user from MockApiCall: \(result)")
        })
    }
    
    //AvoidableFood
    public func getAvoidableFoods() {
        let response = GetAvoidableFoodsRequest().schedule(with: api).receive(on: DispatchQueue.main)
        cancellableSet.insert(response.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("GetAvoidableFood failed due to: \(error)")
            case .finished:
                print("GetAvoidableFood finished.")
            }
        }) { result in
            print("Received avoidable foods: \(result)")
            self.userProfileModel?.setAvoidableFoods(result.data)
        })
    }
    
    public func postAvoidableFoods(avoidedFoodIds: [UUID]) {
        let response = PostAvoidableFoodsRequest(avoidedFoodIds: avoidedFoodIds).schedule(with: api)
        cancellableSet.insert(response.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("PostAvoidableFood failed due to: \(error)")
            case .finished:
                print("PostAvoidableFood finished.")
            }
        }) { _ in
            print("Sent avoided foods")
        })
    }
    
    public func putAvoidableFood(avoidedFoodId: UUID) {
        let response = PutAvoidableFoodRequest(avoidedFoodId: avoidedFoodId).schedule(with: api)
        cancellableSet.insert(response.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("PutAvoidableFood failed due to: \(error)")
            case .finished:
                print("PutAvoidableFood finished.")
            }
        }) { _ in
            print("Sent avoided food")
        })
    }
    
    public func deleteAvoidableFood(avoidedFoodId: UUID) {
        let response = DeleteAvoidableFoodRequest(avoidedFoodId: avoidedFoodId).schedule(with: api)
        cancellableSet.insert(response.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("DeleteAvoidableFood failed due to: \(error)")
            case .finished:
                print("DeleteAvoidableFood finished.")
            }
        }) { _ in
            print("Deleted avoided food")
        })
    }
    
    //Allergy
    public func getAllergies() {
        let response = GetAllergiesRequest().schedule(with: api)
        cancellableSet.insert(response.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("GetAllergies failed due to: \(error)")
            case .finished:
                print("GetAllergies finished.")
            }
        }) { result in
            print("Received allergies: \(result)")
            DispatchQueue.main.async {
                //Implement a possible allergies array in the userprofilemodel to be able to fetch it from the api
            }
        })
    }
    
    public func postAllergies(allergyIds: [UUID]) {
        let response = PostAllergiesRequest(allergyIds: allergyIds).schedule(with: api)
        cancellableSet.insert(response.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("PostAllergies failed due to: \(error)")
            case .finished:
                print("PostAllergies finished.")
            }
        }) { _ in
            print("Sent allergies")
        })
    }
    
    public func putAllergy(allergyId: UUID) {
        let response = PutAllergyRequest(allergyId: allergyId).schedule(with: api)
        cancellableSet.insert(response.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("PutAllergies failed due to: \(error)")
            case .finished:
                print("PutAllergies finished.")
            }
        }) { _ in
            print("Sent allergy")
        })
    }
    
    public func deleteAllergy(allergyId: UUID) {
        let response = DeleteAllergyRequest(allergyId: allergyId).schedule(with: api)
        cancellableSet.insert(response.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("DeleteAllergies failed due to: \(error)")
            case .finished:
                print("DeleteAllergies finished.")
            }
        }) { _ in
            print("Deleted allergy")
        })
    }
    
    //Survey
    public func getSurveys() {
        let response = GetSurveysRequest().schedule(with: api)
        cancellableSet.insert(response.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("GetSurvey failed due to: \(error)")
            case .finished:
                print("GetSurvey finished.")
            }
        }) { result in
            print("Received surveys: \(result)")
            DispatchQueue.main.async {
                self.surveyModel?.addNewSurveys(result.data)
            }
        })
    }
    
    public func getLatestSurveys() {
        let latestSurveyId = UserDefaults.standard.object(forKey: "latestSurveyId") as? String ?? ""
        let response = GetLatestSurveysRequest(latestSurveyId: latestSurveyId).schedule(with: api)
        cancellableSet.insert(response.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("GetLatestSurvey failed due to: \(error)")
            case .finished:
                print("GetLatestSurvey finished.")
            }
        }) { result in
            print("Received surveys: \(result)")
            DispatchQueue.main.async {
                self.surveyModel?.addNewSurveys(result.data)
                if let latestSurvey = result.data.last {
                    self.userDefaultsPublisher?.latestSurveyId = latestSurvey.id.uuidString
                    print("set latest survey id to: \(latestSurvey.id.uuidString)")
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }
                self.surveyModel?.queueUnqueuedSurveys(firstActivity: self.activityModel?.activities.first(where: { $0.startDate > Date() }))
            }
        })
    }
    
    //Answer
    public func postAnswer(answerId: UUID, surveyId: UUID, questionId: UUID) {
        let response = PostAnswerRequest(answerId: answerId,
                                         surveyId: surveyId,
                                         questionId: questionId).schedule(with: api)
        cancellableSet.insert(response.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("PostAnswer failed due to: \(error)")
            case .finished:
                print("PostAnswer finished.")
            }
        }) { _ in
            print("Sent answer")
        })
    }
    
    public func postMoodAnswer(surveyId: UUID, moodAnswers: [MoodAnswer]) {
        let response = PostMoodAnswerRequest(moodAnswers: moodAnswers,
                                             surveyId: surveyId).schedule(with: api)
        cancellableSet.insert(response.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("PostMoodAnswer failed due to: \(error)")
            case .finished:
                print("PostMoodAnswer finished.")
            }
        }) { _ in
            print("Sent moodAnswers")
        })
    }
    
    //Stats
    public func getStats() {
        let response = GetStatsRequest().schedule(with: api)
        cancellableSet.insert(response.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("GetStats failed due to: \(error)")
            case .finished:
                print("GetStats finished.")
            }
        }) { result in
            print("Received stats: \(result)")
            DispatchQueue.main.async {
                self.userProfileModel?.setRegisteredSince(result.data.registeredSince)
                self.userProfileModel?.setPartOfSurveys(result.data.partOfSurveys)
                self.userProfileModel?.setQuestionsAnswered(result.data.questionsAnswered)
            }
        })
    }

    //Profile
    public func postDeviceId() {
        let deviceId = UserDefaults.standard.object(forKey: "deviceId") as? String ?? ""
        let response = PostDeviceIdRequest(deviceId: deviceId).schedule(with: api)
        cancellableSet.insert(response.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("PostDeviceId failed due to: \(error)")
            case .finished:
                print("PostDeviceId finished.")
            }
        }) { _ in
            print("Sent device ID")
        })
    }
}
