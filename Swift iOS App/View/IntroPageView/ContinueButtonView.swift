//
//  ContinueButton.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 10.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct ContinueButtonView: View {
    var text: String
    var color = Color("primaryHeadlineColor")
    
    var body: some View {
        ZStack {
            Text("\(text)")
                .foregroundColor(.white)
                .font(Font.system(size: 22, weight: .bold))
        }.modifier(CardModifier(color: color))
    }
}

struct ContinueButton_Previews: PreviewProvider {
    static var previews: some View {
        ContinueButtonView(text: "OK")
    }
}
