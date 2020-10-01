//
//  FoodCardView.swift
//  sporthealth
//
//  Created by Borchers, Alexander on 17.12.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct FoodCardView: View {
    
    let imageUrl: String
    
    var body: some View {
        Image(imageUrl)
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(15)
            .frame(maxHeight: .infinity)
    }
}

struct FoodCardView_Previews: PreviewProvider {
    static var previews: some View {
        FoodCardView(imageUrl: "brownie")
    }
}
