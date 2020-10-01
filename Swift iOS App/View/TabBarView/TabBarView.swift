//
//  TabBarView.swift
//  sporthealth
//
//  Created by Jakob on 27.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct TabBarView: View {
    // MARK: Stored Instance Properties
    /// The model the diaries shall be read from.
    @EnvironmentObject private var activityModel: ActivityModel
    @EnvironmentObject private var surveyModel: SurveyModel
    @EnvironmentObject private var userProfileModel: UserProfileModel
    @EnvironmentObject private var userDefaultsPublisher: UserDefaultsPublisher
    @State private var showNetworkAlert = false
    
    @State var selectedView = 1
    
    let introScreens: [Any] = [
        QRScannerNewView(currentPage: .constant(0)).self,
        CalendarPermissionView(currentPage: .constant(0)).self,
        HealthPermissionView(currentPage: .constant(0)).self,
        FoodPreferencesView().self,
        DetectedAllergiesView().self,
        IntroDoneView(currentPage: .constant(0)).self
    ]
    
    // MARK: Computed Instance Properties
    var body: some View {
        VStack {
            if userDefaultsPublisher.introDone {
                TabView(selection: $selectedView) {
                    HomescreenView()
                        .tabItem({
                            Image(systemName: "house")
                            Text("Übersicht")
                        })
                        .tag(1)
                    SettingsView(selectedView: $selectedView)
                        .tabItem({
                            Image(systemName: "slider.horizontal.3")
                            Text("Einstellungen")
                        })
                        .tag(2)
                }
            } else {
                PageView(introScreens)
            }
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(selectedView: 1)
            .environmentObject(ActivityModel.mock)
            .environmentObject(SurveyModel.mock)
            .environmentObject(UserProfileModel.mock)
            .environmentObject(HomescreenViewRouter())
            .environmentObject(UserDefaultsPublisher())
    }
}
