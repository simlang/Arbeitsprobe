//
//  ActivityView.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 27.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct ActivityView: View {
    let activity: Activity
    
    var body: some View {
        HStack {
            Text("\(activity.emoji) \(activity.title)")
            Spacer()
            Text("\(activity.formattedDate)")
        }.padding(.horizontal)
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var model = ActivityModel.mock
    
    static var previews: some View {
        ActivityView(activity: model.activities[0])
    }
}
