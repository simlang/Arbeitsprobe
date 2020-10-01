//
//  SurveyTriggerType.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 23.01.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import Foundation

public enum SurveyTriggerType: String, Codable {
    case now = "NOW"
    case absolute = "ABSOLUTE"   // absolute timing: now OR 18:30 - differs from surveyTriggerValue
    case relativeBeforeActivity = "RELATIVE_BEFORE"   // relative timing: before/after/during written activity (OR healthAPI puls detection)
    case relativeAfterActivity = "RELATIVE_AFTER"
}
