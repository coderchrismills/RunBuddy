//
//  RunRowController.swift
//  RunBuddy
//
//  Created by Richard Mills on 1/25/20.
//  Copyright © 2020 Lazy Gardener. All rights reserved.
//

import WatchKit

class RunRowController: NSObject {
    @IBOutlet weak var rowGroup: WKInterfaceGroup!
    @IBOutlet weak var runDescriptionGroup: WKInterfaceGroup!
    @IBOutlet weak var weekDayLabel: WKInterfaceLabel!
    @IBOutlet weak var runImage: WKInterfaceImage!
    @IBOutlet weak var runTimeLabel: WKInterfaceLabel!
    @IBOutlet weak var walkImage: WKInterfaceImage!
    @IBOutlet weak var walkTimeLabel: WKInterfaceLabel!
    @IBOutlet weak var repeatImage: WKInterfaceImage!
    @IBOutlet weak var repeatLabel: WKInterfaceLabel!
    @IBOutlet weak var nonRunDescriptionGroup: WKInterfaceGroup!
    @IBOutlet weak var nonRunLabel: WKInterfaceLabel!
    
    let weekdays = Calendar.autoupdatingCurrent.weekdaySymbols
    
    var run: Run? {
        didSet {
            guard let run = run else { return }
            
            rowGroup.setBackgroundColor(run.color)
            
            weekDayLabel.setText("Week \(run.week): \(weekdays[run.day % 7])")
        
            if run.mileTarget == 0 && run.repeatCount == 0 {
                runDescriptionGroup.setHidden(true)
                nonRunDescriptionGroup.setHidden(false)
                nonRunLabel.setText(run.title)
            } else {
                runDescriptionGroup.setHidden(false)
                nonRunDescriptionGroup.setHidden(true)
                runTimeLabel.setText("\(run.runTitle)")
                walkTimeLabel.setText("\(run.walkTitle)")
                if run.repeatCount > 0 {
                    repeatImage.setImage(UIImage(systemName: "stopwatch.fill"))
                    repeatLabel.setText("\(run.repeatCount)x")
                } else {
                    repeatImage.setImage(UIImage(systemName: "map.fill"))
                    repeatLabel.setText("\(run.mileTarget) Miles")
                }
            }
        }
    }
}
