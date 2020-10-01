//
//  AllergyToggleView.swift
//  sporthealth
//
//  Created by Alex Borchers on 27.01.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI

struct AllergyToggleView: View {
    @EnvironmentObject var userProfileModel: UserProfileModel
    @State var isOn = true
    
    let allergy: Allergy
    
    var body: some View {
        Toggle(isOn: $isOn) {
            Text(allergy.title)
        }.onTapGesture(perform: setAllergy)
    }
    
    func setAllergy() {
        isOn.toggle()
        if isOn {
            userProfileModel.addAllergy(allergy)
        } else {
            userProfileModel.removeAllergy(allergy)
        }
    }
}

struct AllergyToggleView_Previews: PreviewProvider {
    static let userProfileModel = UserProfileModel.mock
    
    static var previews: some View {
        AllergyToggleView(allergy: Allergy(id: UUID(), name: "Nuss", description: "Nussallergie", title: "Nussalelergie"))
            .environmentObject(userProfileModel)
        .padding()
    }
}
