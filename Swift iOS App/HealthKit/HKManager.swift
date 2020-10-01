//
//  HKManager.swift
//  sporthealth
//
//  Created by Alex Borchers on 04.01.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import Foundation
import HealthKit

class HKManager {
    public static var noPermission = false
    public static let healthStore = HKHealthStore()
    public static let allTypes = Set([
        HKObjectType.workoutType(),
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!
    ])
}
