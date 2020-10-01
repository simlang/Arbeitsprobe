//
//  AllActivityView.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 27.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct AllActivityView: View {
    @EnvironmentObject private var model: ActivityModel
    @EnvironmentObject private var surveyModel: SurveyModel
    @EnvironmentObject var viewRouter: HomescreenViewRouter
    
    @State private var showAddActivity: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            List {
                ForEach(self.model.activities.filter({ $0.endDate > Date() }).sorted(by: <)) { activity in
                    NavigationLink(destination: AddActivityView(id: activity.id)) {
                        ActivityView(activity: activity)
                    }
                }
                .onDelete(perform: model.delete(at:))
            }
            Spacer()
        }
        .navigationBarTitle("Deine Aktivitäten", displayMode: .inline)
        .navigationBarItems(trailing: addButton)
        .sheet(isPresented: $showAddActivity) {
            NavigationView {
                AddActivityView(id: nil)
                    .environmentObject(self.surveyModel)
            }.environmentObject(self.model)
        }
    }
    
    private var addButton: some View {
        Button(action: { self.showAddActivity = true }) {
            Image(systemName: "plus")
        }
    }
}

struct AllActivityView_Previews: PreviewProvider {
    static var mockedModel = ActivityModel.mock
    
    static var previews: some View {
        AllActivityView()
            .environmentObject(mockedModel)
            .environmentObject(HomescreenViewRouter())
    }
}
