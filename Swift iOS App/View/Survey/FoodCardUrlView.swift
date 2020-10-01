//
//  FoodCardView.swift
//  sporthealth
//
//  Created by Borchers, Alexander on 17.12.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI
import URLImage

struct FoodCardUrlView: View {
    
    let imageUrl: URL
    
    var body: some View {
        VStack {
            URLImage(self.imageUrl,
                     placeholder: { _ in
                        Image("loadingImage")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(15)
                        .frame(maxHeight: .infinity)
                     }) { proxy in
                            proxy.image
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(15)
                            .frame(maxHeight: .infinity)
            }
        }
    }
}

struct FoodCardUrlView_Previews: PreviewProvider {
    static var previews: some View {
        FoodCardView(imageUrl: "brownie")
    }
}
