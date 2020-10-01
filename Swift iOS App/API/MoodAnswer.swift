//
//  MoodAnswer.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 28.01.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import Foundation

struct MoodAnswer {
    var id: UUID
    var value: Double
}

extension MoodAnswer: Codable { }
