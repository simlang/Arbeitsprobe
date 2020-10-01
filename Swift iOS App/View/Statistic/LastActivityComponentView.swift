//
//  LastActivityComponentView.swift
//  sporthealth
//
//  Created by Borchers, Alexander on 28.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct LastActivityComponentView: View {
    let systemNameImage: String
    let description: String
    let value: String
    let valueDescription: String
    let headerColor: Color
    let hasDetails: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                .cornerRadius(15)
                .frame(height: 90)
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: systemNameImage)
                    Text(description)
                    Spacer()
                    if hasDetails {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }.foregroundColor(headerColor)
                Spacer()
                HStack(alignment: .bottom, spacing: 3) {
                    Text(value)
                        .font(.system(size: 35))
                        .fontWeight(.semibold)
                    Text(valueDescription)
                        .opacity(0.6)
                }.foregroundColor(.primary)
            }.padding(10.0)
        }.frame(height: 90)
    }
}

struct LastActivityComponentView_Previews: PreviewProvider {
    static var previews: some View {
        LastActivityComponentView(systemNameImage: "timer",
                                  description: "Dauer",
                                  value: "455675",
                                  valueDescription: "min",
                                  headerColor: Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)),
                                  hasDetails: true)
    }
}
