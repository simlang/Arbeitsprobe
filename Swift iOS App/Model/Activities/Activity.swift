//
//  Activity.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 27.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import Foundation
import EventKit

public struct Activity {
    
    public var id: UUID
    public var startDate: Date
    public var duration: TimeInterval
    var emoji: String
    var title: String
    var days: [Day]
    let calendarID: String?
    
    init(id: UUID = UUID(), emoji: String = "🏃‍♂️", title: String, date: Date, duration: TimeInterval, days: [Day], cID: String? = nil) {
        self.id = id
        self.startDate = date
        self.duration = duration
        self.emoji = emoji
        self.title = title
        self.days = days
        self.calendarID = cID
        
        if self.emoji.isEmpty {
            self.emoji = getEmojiToDescription(title)
        }
    }
    
    init(event: EKEvent) {
        self.id = UUID()
        self.startDate = event.startDate
        self.duration = event.endDate.timeIntervalSince(startDate)
        self.emoji = ""
        self.title = event.title
        self.days = []
        self.calendarID = event.eventIdentifier
        
        self.emoji = getEmojiToDescription(self.title)
    }
    
    var endDate: Date {
        Date(timeInterval: duration, since: startDate)
    }
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        
        if let startDate = Date().midnight, let endDate = Date().daysAfter(amount: 6), (startDate ... endDate).contains(self.startDate) {
             dateFormatter.dateFormat = "EE HH:mm"
        } else {
            dateFormatter.dateFormat = "dd.MM HH:mm"
        }
        dateFormatter.locale = NSLocale(localeIdentifier: "de_DE") as Locale
        //Maybe implement relative and custom formatting
        return dateFormatter.string(from: startDate)
    }
    
    private func getEmojiToDescription(_ title: String) -> String {
        var emoji = ""
        for titleDict in sportTitles {
            if title.lowercased().contains(titleDict[0].lowercased()) {
                emoji = titleDict[1]
                break
            }
        }
        return emoji
    }
}

extension Activity: Identifiable { }
extension Activity: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
extension Activity: Codable { }
extension Activity: LocalFileStorable {
    static var fileName = "Activities"
}
extension Activity: Comparable {
    public static func < (lhs: Activity, rhs: Activity) -> Bool {
        lhs.startDate < rhs.startDate
    }
}
