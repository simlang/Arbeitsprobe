//
//  ActivitiesModel.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 27.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import Foundation
import Combine
import EventKit

public class ActivityModel {
    var eventStore = EKEventStore()
    var ignoredEvents: [IgnorableEvent] {
        didSet {
            ignoredEvents.saveToFile(path: "IgnoredEvents")
        }
    }
    
    @Published public private(set) var eventsFromCal: [EKEvent] = []
    @Published public private(set) var newActivitiesFromCal = false
    @Published public private(set) var activities: [Activity] {
        didSet {
            activities.saveToFile(path: "Activities")
        }
    }
    
    @Published public private(set) var oldActivities: [Activity] {
        didSet {
            oldActivities.saveToFile(path: "OldActivities")
        }
    }
    
    public init(activities: [Activity]? = nil) {
        self.activities = activities ?? Activity.loadFromFile(from: "Activities")
        self.ignoredEvents = IgnorableEvent.loadFromFile(from: "IgnoredEvents")
        self.oldActivities = Activity.loadFromFile(from: "OldActivities")
        //for fetching Events from the Calendar
        subscribeToUpdates()
        updateEventsFromCal()
        updateOldActivities()
    }
    
    public func getActivity(by id: Activity.ID?) -> Activity? {
        activities.first(where: { $0.id == id })
    }
    public func delete(activity id: Activity.ID) {
        activities.removeAll(where: { $0.id == id })
        updateEventsFromCal()
    }
    public func delete(at offset: IndexSet) {
        guard let index = offset.first else {
            return
        }
        delete(activity: activities[index].id)
    }
    public func save(_ activity: Activity) {
        delete(activity: activity.id)
        
        activities.append(activity)
        activities.sort(by: <)
    }
    public func resetModel() {
        activities = []
    }
    
    public func updateOldActivities() {
        var activitiesNew: [Activity] = []
        var oldActivitiesNew = oldActivities
        
        self.activities.forEach { activity in
            if activity.endDate < Date() {
                oldActivitiesNew.append(activity)
            } else {
                activitiesNew.append(activity)
            }
        }
        
        activities = activitiesNew
        oldActivities = oldActivitiesNew
    }
}

extension ActivityModel {
    private func checkPermissionToCalendar() {
        eventStore.requestAccess(to: .event) { success, _ in
            if !success {
                print("No Access to EventKit")
            }
        }
    }
    
    private func subscribeToUpdates() {
        NotificationCenter.default.addObserver(self, selector: Selector(("storeChanged:")), name: .EKEventStoreChanged, object: eventStore)
    }
    
    @objc func storeChanged(_ notification: NSNotification) {
        updateEventsFromCal()
    }
    
    public func updateEventsFromCal() {
        eventsFromCal = []
        DispatchQueue.main.async {
            self.updateIgnoredEvents()
            self.fetchEvents().forEach { event in
                sportTitles.forEach { sport in
                    print("Sportart: " + sport[0])
                    if event.title.lowercased().contains(sport[0].lowercased()) &&
                        !self.ignoredEvents.contains(where: { $0.id == event.eventIdentifier }) &&
                        !self.calendarEventIsInActivities(event) {
                        self.eventsFromCal.append(event)
                    }
                }
            }
            
            self.newActivitiesFromCal = !self.eventsFromCal.isEmpty
        }
    }
    
    private func calendarEventIsInActivities(_ event: EKEvent) -> Bool {
        activities.contains { $0.calendarID == event.eventIdentifier }
    }
    
    private func fetchEvents() -> [EKEvent] {
        let calendar = Calendar.current

        var someDaysFromNowComponents = DateComponents()
        someDaysFromNowComponents.day = 7
        let someDaysFromNow = calendar.date(byAdding: someDaysFromNowComponents, to: Date())
        
        var predicate: NSPredicate?
        if let fromNow = someDaysFromNow {
            predicate = eventStore.predicateForEvents(withStart: Date(), end: fromNow, calendars: nil)
        }
        
        if let predicate = predicate {
            return eventStore.events(matching: predicate)
        }
        
        return []
    }
    
    public func addEventFromCalendar(event: EKEvent) {
        save(Activity(event: event))
        eventsFromCal.removeAll { $0.eventIdentifier == event.eventIdentifier }
        newActivitiesFromCal = !eventsFromCal.isEmpty
    }
    
    public func ignoreEvent(event: EKEvent) {
        ignoredEvents.append(IgnorableEvent(event))
        DispatchQueue.main.async {
            self.updateIgnoredEvents()
        }
    }
    
    public func ignore(at offset: IndexSet) {
        guard let index = offset.first else {
            return
        }
        ignoreEvent(event: eventsFromCal[index])
        updateEventsFromCal()
    }
    
    public func ignoreAllEvents() {
        eventsFromCal.forEach { ignoredEvents.append(IgnorableEvent($0)) }
        DispatchQueue.main.async {
            self.updateIgnoredEvents()
        }
    }
    
    private func updateIgnoredEvents() {
        self.ignoredEvents = self.ignoredEvents.filter { $0.endDate > Date() }
    }
}

extension ActivityModel: ObservableObject { }

extension EKEvent: Identifiable { }

extension ActivityModel {
    public static var mock: ActivityModel {
        
        let activity1 = Activity(emoji: "🏃‍♂️", title: "Laufen", date: Date(), duration: 3600, days: [])
        let activity2 = Activity(title: "🏋🏻‍♂️ Fitnessstudio", date: Date().daysAfter(amount: 1) ?? Date(), duration: 3600, days: [])
        let activity3 = Activity(title: "⛷ Skifahren", date: Date().daysAfter(amount: 2) ?? Date(), duration: 3600, days: [])
        let activity4 = Activity(title: "🚴🏻‍♂️ Radfahren", date: Date().daysAfter(amount: 3) ?? Date(), duration: 3600, days: [])
        let activity5 = Activity(title: "🏊🏻‍♂️ Schwimmen", date: Date().daysAfter(amount: 7) ?? Date(), duration: 3600, days: [])
        
        let mock = ActivityModel(activities: [activity1, activity2, activity3, activity4, activity5])
        return mock
    }
}
