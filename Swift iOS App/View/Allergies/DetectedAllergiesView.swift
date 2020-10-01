//
//  DetectedAllergiesView.swift
//  sporthealth
//
//  Created by Borchers, Alexander on 02.12.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI
import Combine

struct DetectedAllergiesView: View {
    @EnvironmentObject var userProfileModel: UserProfileModel
    @State var otherAllergies = ""
    
    let columnCount = 4
    let detectedAllergiesInfoText =
    "Mögliche Allergien erkannt. Stimmen diese?"
    let noDetectedAllergiesInfoText =
    "Wir haben durch deine Auswahl keine Allergien entdeckt."
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Unverträglichkeiten")
                .textHeadlineModifier()
            Text(userProfileModel.possibleAllergies.isEmpty ? noDetectedAllergiesInfoText : detectedAllergiesInfoText)
                .font(.system(size: 22))
                .multilineTextAlignment(.center)
            Form {
                if !userProfileModel.possibleAllergies.isEmpty {
                    Section(header: Text("Allergien")) {
                        ForEach(userProfileModel.possibleAllergies) { allergy in
                            AllergyToggleView(allergy: allergy)
                        }
                    }
                }
                Section(header: Text("Sonstige Allergien")) {
                    TextField("Keine...", text: $otherAllergies)
                }
            }
        }
        .onAppear(perform: initializeStates)
        .onDisappear(perform: {
            print("Allergies to POST: " + self.userProfileModel.allergies.description)
            self.userProfileModel.setOtherAllergies(self.otherAllergies)
        })
    }
    
    func getRowCount() -> Int {
        Int((Double(userProfileModel.allergies.count) / Double(columnCount)).rounded(.up))
    }
    
    func getIndex(_ row: Int, _ column: Int) -> Int {
        row * columnCount + column
    }
    
    func initializeStates() {
        otherAllergies = userProfileModel.otherAllergies
    }
}

struct DetectedAllergiesView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DetectedAllergiesView()
                .environmentObject(UserProfileModel.mock)
            Button(action: { }) {
                ContinueButtonView(text: "Fortfahren", color: Color("primaryHeadlineColor"))
            }.padding(.bottom)
        }
    }
}
