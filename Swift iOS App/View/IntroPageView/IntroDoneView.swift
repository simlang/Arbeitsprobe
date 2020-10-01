//
//  IntroDoneView.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 10.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct IntroDoneView: View {
    @EnvironmentObject var userDefaultsPublisher: UserDefaultsPublisher
    
    @Binding var currentPage: Int
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 25)
            Text("Du hast es geschafft!")
                .modifier(TextHeadlineModifier())
            Spacer()
                .frame(height: 25)
            Text("Vielen Dank für dein Vertrauen. Der erste Schritt für eine gesündere Zukunft ist erledigt! \n")
                .modifier(IntroTextModifier())
            Text("Falls du an einer Essstörung leidest, empfehlen wir dir Shifty nicht zu nutzen.")
                .modifier(IntroTextModifier())
            Image("placeholder2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: .infinity)
            Spacer()
            Button(action: { self.userDefaultsPublisher.introDone = true }) {
                ContinueButtonView(text: "OK", color: Color("primaryHeadlineColor"))
            }
        }
    }
}

struct IntroDoneView_Previews: PreviewProvider {
    static var previews: some View {
        IntroDoneView(currentPage: .constant(0))
    }
}
