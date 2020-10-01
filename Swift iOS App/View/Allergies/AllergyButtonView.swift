//
//  AllergyButtonView.swift
//  sporthealth
//
//  Created by Borchers, Alexander on 02.12.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct AllergyButtonView: View {
    @EnvironmentObject var userProfileModel: UserProfileModel
    @State var isMarked = false
    
    let allergy: Allergy
    
    var body: some View {
        Button(action: setAllergy) {
            ZStack {
                Circle()
                    .foregroundColor(isMarked ? Color("primaryHeadlineColor") : Color(UIColor.systemGray))
                    .opacity(0.2)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(isMarked ? Color("primaryHeadlineColor") : Color(UIColor.systemGray), lineWidth: 2)
                    )
                Text(allergy.title)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    func setAllergy() {
        isMarked.toggle()
        if isMarked {
            userProfileModel.addAllergy(allergy)
        } else {
            userProfileModel.removeAllergy(allergy)
        }
    }
}

struct AllergyButtonView_Previews: PreviewProvider {
    static let userProfileModel = UserProfileModel.mock
    
    static var previews: some View {
        AllergyButtonView(isMarked: true, allergy: Allergy(id: UUID(), name: "Nuss", description: "Nussallergie"))
            .environmentObject(userProfileModel)
    }
}
