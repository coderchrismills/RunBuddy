//
//  RunInterfaceController.swift
//  RunBuddy WatchKit Extension
//
//  Created by Richard Mills on 1/26/20.
//  Copyright © 2020 Lazy Gardener. All rights reserved.
//

import WatchKit
import Foundation


class RunInterfaceController: WKInterfaceController {
    @IBOutlet weak var idleGroup: WKInterfaceGroup!
    @IBOutlet weak var runLabel: WKInterfaceLabel!
    @IBOutlet weak var walkLabel: WKInterfaceLabel!
    @IBOutlet weak var repeatLabel: WKInterfaceLabel!
    @IBOutlet weak var repeatImage: WKInterfaceImage!
    
    @IBOutlet weak var activeGroup: WKInterfaceGroup!
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var timeLabel: WKInterfaceTimer!
    
    var runIsActive: Bool = false
    var runStartTime: Date = Date()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let run = context as? Run {
            if runIsActive {
                configureViewForActiveRun(run: run)
            } else {
                configureViewForPreRun(run: run)
            }
        }
    }
    
    func configureViewForPreRun(run: Run) {
        idleGroup.setHidden(false)
        activeGroup.setHidden(true)
        
        runLabel.setText("\(run.run) Minutes")
        let walkSuffix = run.walk > 1 ? "s" : ""
        walkLabel.setText("\(run.walk) Minute\(walkSuffix)")
        if run.repeatCount > 0 {
            repeatImage.setImage(UIImage(systemName: "stopwatch.fill"))
            repeatLabel.setText("\(run.repeatCount)x")
        } else {
            repeatImage.setImage(UIImage(systemName: "map.fill"))
            repeatLabel.setText("\(run.mileTarget) Miles")
        }
    }
    
    func configureViewForActiveRun(run: Run) {
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func runButtonPressed() {
        
    }
    
    @IBAction func pauseButtonPressed() {
        
    }

}
