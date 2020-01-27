//
//  RunInterfaceController.swift
//  RunBuddy WatchKit Extension
//
//  Created by Richard Mills on 1/26/20.
//  Copyright © 2020 Lazy Gardener. All rights reserved.
//

import WatchKit
import Foundation
import AVFoundation

class RunInterfaceController: WKInterfaceController {
    @IBOutlet weak var idleGroup: WKInterfaceGroup!
    @IBOutlet weak var runLabel: WKInterfaceLabel!
    @IBOutlet weak var walkLabel: WKInterfaceLabel!
    @IBOutlet weak var repeatLabel: WKInterfaceLabel!
    @IBOutlet weak var repeatImage: WKInterfaceImage!
    
    @IBOutlet weak var activeGroup: WKInterfaceGroup!
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var timeLabel: WKInterfaceTimer!
    
    @IBOutlet weak var pauseButton: WKInterfaceButton!
    
    var runIsActive: Bool = false
    var isPaused: Bool = false
    var runStartTime: Date = Date()
    var elapsedTime: TimeInterval = 0
    var duration: TimeInterval = 0
    var activeRun: Run?
    var timer: Timer = Timer()
    var currentRunPhase: RunPhase = .warmup
    var currentInterval = 0
    
    let synth = AVSpeechSynthesizer()
    let beginRunUtterance = AVSpeechUtterance(string: "Begin warmup")
    let pausingWorkoutUtterance = AVSpeechUtterance(string: "Pausing workout")
    let resumingWorkoutUtterance = AVSpeechUtterance(string: "Resuming workout")
    let workoutCompleteUtterance = AVSpeechUtterance(string: "Workout complete")
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        synth.delegate = self
        
        activeRun = context as? Run
        if let run = activeRun {
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
        idleGroup.setHidden(true)
        activeGroup.setHidden(false)
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
        pauseButton.setTitle("Pause")
        
        if runIsActive {
            timeLabel.start()
            return
        }
        
        startTimer(duration: 5)
        
        currentRunPhase = .warmup
        titleLabel.setText("Warmup")
        
        idleGroup.setHidden(true)
        activeGroup.setHidden(false)
        
        runIsActive = true
    
        synth.speak(beginRunUtterance)
    }
    
    func startTimer(duration: TimeInterval) {
        self.duration = duration
        runStartTime = Date()
        isPaused = false
        let timeDelta = duration - elapsedTime
        timer = Timer.scheduledTimer(timeInterval: timeDelta, target: self, selector: #selector(timerDone), userInfo: nil, repeats: false)
        timeLabel.setDate(Date(timeIntervalSinceNow: timeDelta))
        timeLabel.start()
        pauseButton.setTitle("Pause")
        // at 5s left WKInterfaceDevice.current().play(.notification)
    }
    
    @IBAction func pauseButtonPressed() {
        if isPaused {
            startTimer(duration: duration)
            synth.speak(resumingWorkoutUtterance)
        } else {
            isPaused = true
            synth.speak(pausingWorkoutUtterance)
            let paused = Date()
            elapsedTime += paused.timeIntervalSince(runStartTime)
            
            //stop watchkit timer on the screen
            timeLabel.stop()
            
            //stop the ticking of the internal timer
            timer.invalidate()
            
            //do whatever UI changes you need to
            pauseButton.setTitle("Resume")
        }
    }
    
    @IBAction func cancelButtonPressed() {
        runIsActive = false
        if let run = activeRun {
            configureViewForPreRun(run: run)
        }
    }
    
    @objc func timerDone() {
        switch currentRunPhase {
        case .warmup:
            currentRunPhase = .run
            titleLabel.setText("Run")
            let runUtterance = AVSpeechUtterance(string: "Run for \(activeRun!.run) Minutes")
            synth.speak(runUtterance)
            startTimer(duration: TimeInterval(activeRun!.run * 60))
        case .run:
            currentRunPhase = .walk
            titleLabel.setText("Walk")
            let walkSuffix = activeRun!.walk > 1 ? "s" : ""
            let walkUtterance = AVSpeechUtterance(string: "Walk for \(activeRun!.run) Minute\(walkSuffix)")
            synth.speak(walkUtterance)
            startTimer(duration: TimeInterval(activeRun!.walk * 60))
        case .walk:
            currentInterval = currentInterval + 1
            if activeRun?.mode == RunMode.interval && currentInterval >= (activeRun?.repeatCount ?? 0) {
                endRun()
            } else {
                currentRunPhase = .run
                titleLabel.setText("Run")
                let runUtterance = AVSpeechUtterance(string: "Run for \(activeRun!.run) Minutes")
                synth.speak(runUtterance)
                startTimer(duration: TimeInterval(activeRun!.run * 60))
            }
        case .done:
            currentRunPhase = .done
            titleLabel.setText("Done")
        }
    }
    
    func endRun() {
        currentRunPhase = .done
        titleLabel.setText("Done")
        timeLabel.stop()
        timer.invalidate()
        synth.speak(workoutCompleteUtterance)
        popToRootController()
    }
}

extension RunInterfaceController: AVSpeechSynthesizerDelegate {
    
}
