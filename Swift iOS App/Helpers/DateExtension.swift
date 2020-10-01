//
//  DateExtension.swift
//  sporthealth
//
//  Created by Dominic Henze on 10.10.19.
//  Copyright © 2019 TUM LS1. All rights reserved.
//

import Foundation

extension Date {
    static var yesterday: Date? { Date().dayBefore }
    static var tomorrow: Date? { Date().dayAfter }
    
    var dayBefore: Date? {
        if let noon = noon {
            return Calendar.current.date(byAdding: .day, value: -1, to: noon)
        }
        return nil
    }
    
    var dayAfter: Date? {
        if let noon = noon {
            return Calendar.current.date(byAdding: .day, value: 1, to: noon)
        }
        return nil
    }
    var midnight: Date? {
        Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)
    }
    
    var noon: Date? {
        Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)
    }
    
    func daysBefore(amount: Int) -> Date? {
        if let noon = noon {
            return Calendar.current.date(byAdding: .day, value: -amount, to: noon)
        }
        return nil
    }
    func daysAfter(amount: Int) -> Date? {
        if let noon = noon {
            return Calendar.current.date(byAdding: .day, value: amount, to: noon)
        }
        return nil
    }
    func roundToNextFullHour() -> Date? {
        var components = Calendar.current.dateComponents([.minute], from: self)
        let minute = components.minute ?? 0
        components.minute = 60 - minute
        return Calendar.current.date(byAdding: components, to: self)
    }
}
