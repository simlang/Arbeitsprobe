//
//  HomescreenView.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 02.12.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI
import Combine

struct HomescreenView: View {
    @EnvironmentObject private var userProfileModel: UserProfileModel
    @EnvironmentObject private var userDefaultsPublisher: UserDefaultsPublisher
    @EnvironmentObject private var model: ActivityModel
    @State private var showAddActivity: Bool = false
    
    @EnvironmentObject private var surveyModel: SurveyModel
    @EnvironmentObject private var activityModel: ActivityModel
    @EnvironmentObject private var survey: Survey
    
    @State private var cancellableSet: Set<AnyCancellable> = []
    
    /// Indicator whether the add account sheet is supposed to be presented.
    @State private var presentAddAccount = false
    
    /// If true, the Survey Card will be shown in the Homescreen View
    @State private var showSurvey: Bool = false
    @State var activeSurvey: Survey?
    let checkIfSurveyReadyTimer = Timer.publish(every: 5, on: .current, in: .common).autoconnect()
    
    private var activities: [Activity] {
        model.activities.sorted(by: <)
    }
    
    init() {
        UINavigationBar.appearance().backgroundColor = UIColor.systemGray6
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 15) {
                    if showSurvey {
                        VStack(spacing: 15) {
                            SurveyView(survey: activeSurvey ?? SurveyModel.mock.surveys.first!)
                        }
                    }
                    HStack {
                        Text("Aktivitäten")
                            .font(Font.system(size: 22, weight: .medium))
                        Spacer()
                        Button(action: { self.showAddActivity = true }) {
                            AddNewButtonView()
                        }
                        .sheet(isPresented: $showAddActivity) {
                            NavigationView {
                                AddActivityView(id: nil)
                                    .environmentObject(self.surveyModel)
                            }.environmentObject(self.model)
                        }
                    }.padding(.horizontal)
                    ActivitySummaryView(showAddActivity: $showAddActivity)
                    HStack {
                        Text("Statistiken")
                            .font(Font.system(size: 22, weight: .medium))
                            .padding(.horizontal)
                        Spacer()
                    }
                    HStack {
                        StatisticSurveyView(value: String(userProfileModel.questionsAnswered), description: "Beantwortete Fragen")
                            .frame(maxWidth: .infinity)
                            .padding(10)
                        Divider()
                        StatisticSurveyView(value: userProfileModel.getDaysInSurvey(),
                                            description: "\(userProfileModel.getDaysInSurvey() == "1" ? "Tag" : "Tage") in der Studie")
                            .frame(maxWidth: .infinity)
                            .padding(10)
                    }.background(Color.white)
                        .cornerRadius(15)
                    StatisticOverviewView()
                }.padding()
                .navigationBarTitle("Übersicht")
                .background(Color(UIColor.systemGray6))
                .onAppear(perform: {
                    self.getSurveys()
                    self.checkActiveSurveys()
                    self.updateStats()
                })
                .onDisappear(perform: {
                    self.showSurvey = false
                    self.activeSurvey = nil
                })
                .onReceive(checkIfSurveyReadyTimer) { _ in
                    self.checkActiveSurveys()
                }
            }
        }
    }
    
    private func getSurveys() {
        let latestSurveyId = UserDefaults.standard.object(forKey: "latestSurveyId") as? String ?? ""
        let apiRequestManager = ApiRequestManager()
        let response = apiRequestManager.getLatestSurveys(latestSurveyId: latestSurveyId)
        
        response.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("GetLatestSurveyOnHomescreen failed due to: \(error)")
            case .finished:
                print("GetLatestSurveyOnHomescreen finished.")
            }
        }) { result in
            print("Received surveys onHomescreen: \(result)")
            DispatchQueue.main.async {
                self.surveyModel.addNewSurveys(result.data)
                if let latestSurvey = result.data.last {
                    self.userDefaultsPublisher.latestSurveyId = latestSurvey.id.uuidString
                    print("set latest survey id to: \(latestSurvey.id.uuidString)")
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }
                self.surveyModel.queueUnqueuedSurveys(firstActivity: self.activityModel.activities.first(where: { $0.startDate > Date() }))
                self.checkActiveSurveys()
            }
        }
        .store(in: &cancellableSet)
    }
    
    private func checkActiveSurveys() {
        if let filteredFirstSurvey = self.getActiveSurveys().first {
            self.activeSurvey = filteredFirstSurvey
            self.showSurvey = true
        }
    }
    
    private func getActiveSurveys() -> [Survey] {
        self.surveyModel.surveys.filter({ $0.isQueued == true }).filter({ $0.triggerTimestamp < Date() })
    }
    private var profilePicture: some View {
        Image("mockProfilePicture")
            .resizable()
            .clipShape(Circle())
            .aspectRatio(contentMode: ContentMode.fit)
            .frame(height: 50)
    }
    
    /// A plus button that is used to add a new account.
    private var addButton: some View {
        Button(action: { self.presentAddAccount = true }) {
            Image(systemName: "plus")
        }
    }
    
    private func updateStats() {
        let requestManager = ApiRequestManagerWithHandling(userProfileModel: userProfileModel)
        
        if UserProfileModel.updatedStats {
            return
        }

        requestManager.getStats()
        UserProfileModel.updatedStats = true
    }
}

struct HomescreenView_Previews: PreviewProvider {
    static var mockedModel = ActivityModel.mock
    
    static var previews: some View {
        HomescreenView()
            .environmentObject(mockedModel)
            .environmentObject(SurveyModel.mock)
            .environmentObject(SurveyModel.mock.surveys[0])
            .environmentObject(UserProfileModel())
    }
}
