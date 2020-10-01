//
//  Notification.swift
//  sporthealth
//
//  Created by Chuying He on 16.12.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
import AuthenticationServices

class AppNotification {
    
    @EnvironmentObject private var activityModel: ActivityModel
    @EnvironmentObject private var surveyModel: SurveyModel
    
    //init() {
        
        //print("number of mock survey: \(String(describing: SurveyModel.mock.surveys.count))")
        //surveys = SurveyModel.surveys
        //activities = ActivityModel.mock.activities
        //print("number of survey: \(String(describing: self.surveyModel?.surveys.count))")
        //print("number of activity: \(String(describing: self.activityModel?.activities.count))")
    //}
    
    
    func queueLocalNotification(date: Date) {
        let center = UNUserNotificationCenter.current()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .day, .month, .hour, .minute, .second], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = getRequest(repeats: false, trigger: trigger)
        center.add(request)
    }
    
    func getPendingRequests() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            print("Current Requests: ________________")
            for request in requests {
                print("request: \(request.trigger.debugDescription)")
            }
            print("__________________________________")
        })
    }
    
    func deletePendingRequests() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
    
    func getRequest(repeats: Bool, trigger: UNNotificationTrigger) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = "Eine neue Umfrage steht bereit"
        content.body = "Klicke hier um sie zu beantworten."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]   // dictionary of custom data
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        return request
    }
    
    enum ErrorNotification: Error {
        case noActivity
        case noSurvey
    }
}
