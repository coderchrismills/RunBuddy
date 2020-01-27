//
//  InterfaceController.swift
//  RunBuddy WatchKit Extension
//
//  Created by Richard Mills on 1/25/20.
//  Copyright © 2020 Lazy Gardener. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit

class InterfaceController: WKInterfaceController {
    @IBOutlet weak var tableView: WKInterfaceTable!
    
    var runs: [Run] = []
    let healthStore = HKHealthStore()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        runs = Run.getAllRuns()
        
        tableView.setNumberOfRows(runs.count, withRowType: "RunRow")
        
        for index in 0..<tableView.numberOfRows {
            guard let controller = tableView.rowController(at: index) as? RunRowController else { continue }
            controller.run = runs[index]
        }
        
        let typesToShare: Set = [ HKQuantityType.workoutType() ]
        let typesToRead: Set = [ HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)! ]
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead, completion: { (success, error) in
            
        })
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let run = runs[rowIndex]
        if run.mileTarget == 0 && run.repeatCount == 0 {
            return
        }
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .outdoor
        let sessionContext = WorkoutSessionContext(healthStore: healthStore, configuration: configuration, run: run)
        
        pushController(withName: "Run", context: sessionContext)
    }
}
