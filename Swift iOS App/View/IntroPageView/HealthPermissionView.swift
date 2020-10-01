//
//  HealthPermissionView.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 10.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI
import HealthKit

struct HealthPermissionView: View {
    @Binding var currentPage: Int
    @State private var showAlert = false
    
    let requestAuthorizationText = """
        Um shifty verwenden zu können,
        müssen Sie den Zugriff auf die Apple Health Daten erlauben.
        Öffnen Sie dazu Einstellungen -> Health -> Datenzugriff & Geräte
        """
    
    var body: some View {
        VStack {
            if UIDevice.current.userInterfaceIdiom == .phone {
                VStack {
                    Spacer()
                    Text("Dürfen wir auf deine Apple Health Daten zugreifen?")
                        .modifier(TextHeadlineModifier())
                        .padding()
                    Text("""
                    Mithilfe der Health Daten erhältst du viele nützliche Informationen
                    über deine letzten sportlichen Aktivitäten.
                    """)
                        .modifier(IntroTextModifier())
                    Spacer()
                    Text("Falls du dich später umentscheiden willst, kannst du immer in deinen Einstellungen die Erlaubnis erteilen.")
                        .modifier(IntroTextModifier())
                    Image("placeholder1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: .infinity)
                    Spacer()
                    Button(action: getHealthPermissions) {
                        ContinueButtonView(text: "OK", color: Color("primaryHeadlineColor"))
                    }
                }
            } else {
                VStack {
                    Text("Apple Health Daten")
                        .textHeadlineModifier()
                    Spacer()
                    Text("""
                        Da du shifty nicht auf einem iPhone benutzt,
                        können wir dir keine genauen Statistiken zu deiner letzten Aktivität bereitstellen.
                        """)
                        .modifier(IntroTextModifier())
                    Spacer()
                    Image("placeholder1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: .infinity)
                    Spacer()
                    Button(action: {
                        self.currentPage += 1
                    }) {
                        ContinueButtonView(text: "Weiter")
                    }
                }
            }
        }
    }
    
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { success in
                print("Settings opened: \(success)")
            })
        }
    }
    
    func getHealthPermissions() {
        let healthStore = HKManager.healthStore
        
        healthStore.requestAuthorization(toShare: HKManager.allTypes, read: HKManager.allTypes) { success, _ in
            if success {
                //YES means that the permission screen was successfully shown and NO means that there was an error presenting the permissions screen.
                for hkType in HKManager.allTypes {
                    //This method checks the authorization status for saving data.
                    //check the status whenever we need it! User might have changed the settings.
                    if healthStore.authorizationStatus(for: hkType) != .sharingAuthorized {
                        self.showAlert = true
                        self.incCurrentPageOnce()
                        return
                    }
                }
                self.showAlert = false
                self.incCurrentPageOnce()
            } else {
                self.showAlert = true
                return
            }
        }
    }
    func incCurrentPageOnce() {
        enum OnlyOnce { static var incremented = false }
        if !OnlyOnce.incremented {
            OnlyOnce.incremented = true
            self.currentPage += 1
        }
    }
}

struct HealthPermissionView_Previews: PreviewProvider {
    static var previews: some View {
        HealthPermissionView(currentPage: .constant(0))
    }
}
