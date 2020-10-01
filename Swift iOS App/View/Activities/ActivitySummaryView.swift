//
//  ActivitySummaryView.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 27.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct ActivitySummaryView: View {
    @EnvironmentObject var viewRouter: HomescreenViewRouter
    @EnvironmentObject private var model: ActivityModel
    
    @State var showNewActivities = false
    @Binding var showAddActivity: Bool
    
    var body: some View {
        NavigationLink(destination: AllActivityView()) {
            VStack(spacing: 15) {
                if !self.model.activities.isEmpty {
                    Spacer()
                        .frame(height: 3)
                    HStack {
                        Text("Deine nächsten Aktivitäten")
                            .font(Font.system(size: 16, weight: .medium))
                            .padding(.horizontal)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                    ForEach(self.model.activities.filter({ $0.endDate > Date() }).sorted(by: <)) { activity in
                        if self.model.activities.sorted(by: <).firstIndex(of: activity) ?? 3 < 3 {
                            ActivityView(activity: activity)
                        }
                    }.padding(3)
                    Spacer()
                        .frame(height: 3)
                    if self.model.newActivitiesFromCal {
                        Divider()
                    }
                }
                if self.model.newActivitiesFromCal {
                    HStack {
                        Text("Neue Aktivitäten gefunden")
                            .padding(.horizontal)
                            .font(Font.system(size: 20))
                        Spacer()
                        Button(action: {
                            self.showNewActivities = true
                            self.model.updateEventsFromCal()
                        }) {
                            calendarButton
                        }
                        .padding(.horizontal)
                        .sheet(isPresented: $showNewActivities) {
                                self.newActivities
                        }
                    }
                .padding(5)
                }
                if !self.model.activities.isEmpty {
                Divider()
                    VStack(spacing: 20) {
                        ContinueButtonView(text: "Alle anzeigen", color: Color("primaryHeadlineColor"))
                    }
                    Spacer()
                        .frame(height: 3)
                }
            }.background(Color.white)
                .cornerRadius(15)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension ActivitySummaryView {
    var calendarButton: some View {
        Circle()
        .frame(width: 40, height: 40, alignment: .center)
        .foregroundColor(Color("primaryHeadlineColor"))
        .overlay(
             Image(systemName: "calendar.badge.plus")
                .font(Font.system(size: 18, weight: .light))
                .foregroundColor(Color.white)
        )
    }
    
    var newActivities: some View {
        var dateFormatter: DateFormatter {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM hh:mm"
            
            return dateFormatter
        }
        
        return VStack {
            Text("Neue Aktivitäten")
                .modifier(TextHeadlineModifier())
                .padding(20)
            List {
                ForEach(self.model.eventsFromCal) { event in
                    HStack {
                        Spacer()
                        VStack(alignment: .center, spacing: 10) {
                            Text(event.title)
                                .font(Font.system(size: 15, weight: .bold))
                            HStack(alignment: .center, spacing: 10) {
                                Text("\(dateFormatter.string(from: event.startDate))")
                                Text("bis")
                                Text("\(dateFormatter.string(from: event.endDate))")
                            }
                        }
                        Spacer()
                        Button(action: { self.model.addEventFromCalendar(event: event) }) {
                            AddNewButtonView()
                        }
                    }.padding(4)
                }
                .onDelete(perform: model.ignore(at:))
            }
            Button(action: {
                self.model.ignoreAllEvents()
                self.model.updateEventsFromCal()
                self.showNewActivities = false
            }) {
                ContinueButtonView(text: "Ignorieren")
            }
        }
    }
}

struct ActivitySummaryView_Previews: PreviewProvider {
    static var mockedModel = ActivityModel.mock
    @State static var showAddActivity = false
    
    static var previews: some View {
        VStack {
            Spacer()
            ActivitySummaryView(showAddActivity: $showAddActivity)
                .frame(maxWidth: 350, maxHeight: 290, alignment: .center)
                .padding(10)
                .background(Color.white)
                .cornerRadius(25)
                .environmentObject(mockedModel)
                .environmentObject(HomescreenViewRouter())
            Spacer()
        }.background(Color.gray)
            .previewLayout(.sizeThatFits)
    }
}
