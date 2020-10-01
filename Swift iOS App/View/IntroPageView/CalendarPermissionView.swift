//
//  CalendarPermissionView.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 09.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI
import EventKit
import URLImage

struct CalendarPermissionView: View {
    @Binding var currentPage: Int
    @EnvironmentObject var userProfileModel: UserProfileModel
    
    let eventStore = EKEventStore()
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 25)
            Text("Dürfen wir auf deinen\n Kalender zugreifen?")
                .modifier(TextHeadlineModifier())
            Spacer()
                .frame(height: 25)
            Text("Für die optimale Nutzung dieser App durchsuchen wir deinen Kalender nach sportlichen Aktivitäten. \n")
                .modifier(IntroTextModifier())
            Text("Du kannst deine Aktivitäten auch\n manuell hinzufügen.")
                .modifier(IntroTextModifier())
            Image("placeholder2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: .infinity)
            preloadUrlImages
            Spacer()
            VStack {
                Button(action: requestAccessToCalendar) {
                    ContinueButtonView(text: "OK", color: Color("primaryHeadlineColor"))
                }
                Button(action: { self.currentPage = self.currentPage + 1 }) {
                    Text("Später")
                }.foregroundColor(Color("primaryHeadlineColor"))
                .padding()
            }.padding(.horizontal)
        }
    }
    
    private var preloadUrlImages: some View {
        HStack {
            ForEach(0..<self.userProfileModel.avoidableFoods.count) { index in
                URLImage(self.userProfileModel.avoidableFoods[index].imageUrl,
                         placeholder: { _ in
                   Image("loadingImage")
                    .renderingMode(.original)
                    .resizable()
                    .frame(width: 1, height: 1, alignment: .center)
                    .opacity(0)
                }) { proxy in
                    proxy.image
                    .renderingMode(.original)
                    .resizable()
                    .frame(width: 1, height: 1, alignment: .center)
                    .opacity(0)
                }
            }
            Spacer()
        }
    }
    
    func requestAccessToCalendar() {
        eventStore.requestAccess(to: EKEntityType.event, completion: {(accessGranted: Bool, _) in
            if accessGranted == true {
                self.incCurrentPageOnce()
            }
        })
    }
    func incCurrentPageOnce() {
        enum OnlyOnce { static var incremented = false }
        if !OnlyOnce.incremented {
            OnlyOnce.incremented = true
            self.currentPage += 1
        }
    }
}

struct CalendarPermissionView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarPermissionView(currentPage: .constant(0))
    }
}
