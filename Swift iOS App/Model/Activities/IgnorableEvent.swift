//
//  IgnorableEvent.swift
//  sporthealth
//
//  Created by Simon Langrieger on 21.01.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import Foundation
import EventKit

struct IgnorableEvent {
    let id: String
    let endDate: Date
    
    init(id: String, endDate: Date) {
        self.id = id
        self.endDate = endDate
    }
    
    init(_ event: EKEvent) {
        self.id = event.eventIdentifier
        self.endDate = event.endDate
    }
}

extension IgnorableEvent: LocalFileStorable {
    static var fileName = "IgnoredEvents"
}
