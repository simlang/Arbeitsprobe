//
//  PageView.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 09.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct PageView: View {
    @EnvironmentObject var userProfileModel: UserProfileModel
    
    var screensToShow: [Any]
    let transitionDuration = 0.4
    
    @State var currentPage = 0
    
    init(_ views: [Any]) {
        screensToShow = views
    }
    
    var body: some View {
        VStack {
            if screensToShow[currentPage] is QRScannerNewView {
                QRScannerNewView(currentPage: $currentPage)
                    .modifier(PageViewTransitionModifier(duration: transitionDuration))
            }
            if screensToShow[currentPage] is CalendarPermissionView {
                CalendarPermissionView(currentPage: $currentPage)
                    .modifier(PageViewTransitionModifier(duration: transitionDuration))
            }
            if screensToShow[currentPage] is HealthPermissionView {
                HealthPermissionView(currentPage: $currentPage)
                    .modifier(PageViewTransitionModifier(duration: transitionDuration))
            }
            if screensToShow[currentPage] is FoodPreferencesView {
                VStack {
                    FoodPreferencesView()
                        .modifier(PageViewTransitionModifier(duration: transitionDuration))
                        .padding(.horizontal, 8)
                    Spacer()
                        .frame(height: 20)
                    Button(action: {
                        self.userProfileModel.setPossibleAllergies()
                        self.currentPage += 1
                    }) {
                        ContinueButtonView(text: "Fortfahren", color: Color("primaryHeadlineColor"))
                    }
                }
            }
            if screensToShow[currentPage] is DetectedAllergiesView {
                VStack {
                    DetectedAllergiesView()
                        .modifier(PageViewTransitionModifier(duration: transitionDuration))
                    Button(action: {
                        self.currentPage += 1
                        self.postAllergies()
                    }) {
                        ContinueButtonView(text: "Fortfahren", color: Color("primaryHeadlineColor"))
                    }
                }
            }
            if screensToShow[currentPage] is IntroDoneView {
                IntroDoneView(currentPage: $currentPage)
                    .modifier(PageViewTransitionModifier(duration: transitionDuration))
            }
            CustomProgressBarView(currentPage: currentPage, maxPage: 6)
                //.padding(.bottom)
        }
    }
    
    func postAllergies() {
        let requestManager = ApiRequestManagerWithHandling(userProfileModel: self.userProfileModel)
        requestManager.postAllergies(
            allergyIds: self.userProfileModel.allergies.map { $0.id }
        )
    }    
}

struct PageView_Previews: PreviewProvider {
    static let userProfileModel = UserProfileModel.mock
    
    static let screens: [Any] = [
        QRScannerNewView(currentPage: .constant(0)).self,
        CalendarPermissionView(currentPage: .constant(0)).self,
        HealthPermissionView(currentPage: .constant(0)).self,
        FoodPreferencesView(),
        DetectedAllergiesView(),
        IntroDoneView(currentPage: .constant(0)).self
    ]
    
    static var previews: some View {
        PageView(screens)
            .environmentObject(userProfileModel)
    }
}
