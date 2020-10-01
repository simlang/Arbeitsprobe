//
//  CameraPermissionsView.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 09.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct CameraPermissionsView: View {
    @Binding var currentPage: Int
    @Binding var pageCounter: Int
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 25)
            Text("Wir benötigen Zugriff auf \n deine Kamera")
                .modifier(TextHeadlineModifier())
            Spacer()
                .frame(height: 25)
            Text("Damit die App automatisch deine Daten einlesen kann, müssen wir deinen persönlichen QR Code scannen können. \n")
                .modifier(IntroTextModifier())
            Text("Gib uns dafür bitte Zugriff auf deine Kamera.")
                .modifier(IntroTextModifier())
            Image("placeholder3")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: .infinity)
            Spacer()
            Button(action: {
                self.currentPage += 1
                self.pageCounter += 1
            }) {
                ContinueButtonView(text: "OK", color: Color("primaryHeadlineColor"))
                    .padding(.horizontal)
            }
        }
    }
}

struct CameraPermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        CameraPermissionsView(currentPage: .constant(0), pageCounter: .constant(0))
    }
}
