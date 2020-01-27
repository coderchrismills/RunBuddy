//
//  WorkoutSessionContext.swift
//  RunBuddy WatchKit Extension
//
//  Created by Richard Mills on 1/26/20.
//  Copyright © 2020 Lazy Gardener. All rights reserved.
//

import Foundation
import HealthKit

class WorkoutSessionContext {
    
    let configuration: HKWorkoutConfiguration
    let healthStore: HKHealthStore
    let run: Run
    
    init(healthStore: HKHealthStore, configuration: HKWorkoutConfiguration, run: Run) {
        self.healthStore = healthStore
        self.configuration = configuration
        self.run = run
    }
    
}

