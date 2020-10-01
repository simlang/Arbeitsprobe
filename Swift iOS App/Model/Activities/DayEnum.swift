//
//  DayEnum.swift
//  sporthealth
//
//  Created by Ennemoser, Franz Josef on 28.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import Combine
import SwiftUI

enum Day: Int, CaseIterable, Identifiable, Comparable, Codable {
    
    static func < (lhs: Day, rhs: Day) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    case monday = 0
    case tuesday = 1
    case wednesday = 2
    case thursday = 3
    case friday = 4
    case saturday = 5
    case sunday = 6

    var id: Day {
        self
    }

    var fullString: String {
        switch self {
        case .monday: return "Jeden Montag"
        case .tuesday: return "Jeden Dienstag"
        case .wednesday: return "Jeden Mittwoch"
        case .thursday: return "Jeden Donnerstag"
        case .friday: return "Jeden Freitag"
        case .saturday: return "Jeden Samstag"
        case .sunday: return "Jeden Sonntag"
        }
    }
    var abbreviation: String {
        switch self {
        case .monday: return "Mo"
        case .tuesday: return "Di"
        case .wednesday: return "Mi"
        case .thursday: return "Do"
        case .friday: return "Fr"
        case .saturday: return "Sa"
        case .sunday: return "So"
        }
    }
}
