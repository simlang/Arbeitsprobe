//
//  TimeIntervalExtension.swift
//  sporthealth
//
//  Created by Simon Langrieger on 15.01.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import Foundation

extension TimeInterval {
    
    var stringFormatted: String {
        let interval = Int(self)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 60 / 60) % 24
        var description = ""
        if hours > 0 {
            description.append(hours.description + "h " + minutes.description + "min")
        } else {
            if minutes > 0 {
                description.append(minutes.description + "min " + seconds.description + "s")
            } else {
                description.append(seconds.description + "s")
            }
        }
        return description
    }
}
