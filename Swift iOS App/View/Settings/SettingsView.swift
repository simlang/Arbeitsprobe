//
//  SettingsView.swift
//  sporthealth
//
//  Created by Jakob on 27.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI
import Squid
import Combine

struct SettingsView: View {
    @EnvironmentObject private var userProfileModel: UserProfileModel
    @EnvironmentObject private var activityModel: ActivityModel
    @EnvironmentObject private var surveyModel: SurveyModel
    @EnvironmentObject private var userDefaultPublisher: UserDefaultsPublisher
    @State private var showAlert = false
    @Binding var selectedView: Int
    
    let requestManager = ApiRequestManagerWithHandling()
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Angaben ändern")) {
                        NavigationLink(destination: FoodPreferencesView()) {
                            Text("Präferenzen ändern")
                        }
                    }
                    
                    Section {
                        Button(action: { self.showAlert = true }) {
                            Text("App zurücksetzen")
                                .foregroundColor(.red)
                        }.alert(isPresented: $showAlert) {
                            Alert(title: Text("Alle Nutzerdaten löschen"),
                                  message: Text("Sind Sie sicher, dass sie die gesamte App zurücksetzen wollen?"),
                                  primaryButton: .destructive(Text("Zurücksetzen")) { self.resetApp() },
                                  secondaryButton: .cancel(Text("Abbrechen")))
                        }
                    }
                }

                Spacer()
                HStack {
                    Spacer()
                    Text("Made with ❤️ in Munich")
                        .font(Font.system(size: 14, weight: .light))
                    Spacer()
                }
                Spacer()
                    .frame(height: 15)
            }.navigationBarTitle("Einstellungen")
            .background(Color(UIColor.systemGray6))
        }.onAppear(perform: getAvoidableFoods)
    }
    
    private func getAvoidableFoods() {
        let requestManager = ApiRequestManagerWithHandling(userProfileModel: userProfileModel)
        
        requestManager.getAvoidableFoods()
    }
    
    private func resetApp() {
        print("Resetting the app...")
        
        self.activityModel.resetModel()
        self.userProfileModel.resetModel()
        self.surveyModel.resetModel()
        
        self.userDefaultPublisher.latestSurveyId = ""
        self.userDefaultPublisher.apiKey = ""
        withAnimation(.linear(duration: 0.5)) {
            self.userDefaultPublisher.introDone = false
            self.selectedView = 1
        }
        print("Reset the app.")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(selectedView: .constant(2))
            .environmentObject(UserProfileModel.mock)
            .environmentObject(UserDefaultsPublisher())
    }
}
