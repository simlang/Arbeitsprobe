//
//  AddNewButtonView.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 02.12.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct AddNewButtonView: View {
    var body: some View {
        Circle()
        .frame(width: 30, height: 30, alignment: .center)
        .foregroundColor(Color("primaryHeadlineColor"))
        .overlay(
             Image(systemName: "plus")
                .font(Font.system(size: 18, weight: .medium))
                .foregroundColor(Color.white)
        )
    }
}

struct AddNewButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewButtonView()
    }
}
