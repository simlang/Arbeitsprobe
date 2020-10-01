//
//  MotherView.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 03.12.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct HomescreenMotherView: View {
    @EnvironmentObject var viewRouter: HomescreenViewRouter
    
    var body: some View {
        VStack {
            if viewRouter.currentPage == "page1" {
                HomescreenView()
                    .navigationViewReverseTransitionViewModifier(duration: 0.4)
            } else if viewRouter.currentPage == "page2" {
                AllActivityView()
                    .navigationViewTransitionViewModifier(duration: 0.4)
            }
        }
    }
}

struct HomescreenMotherView_Previews: PreviewProvider {
    static var previews: some View {
        HomescreenMotherView()
            .environmentObject(HomescreenViewRouter())
            .environmentObject(ActivityModel.mock)
    }
}
