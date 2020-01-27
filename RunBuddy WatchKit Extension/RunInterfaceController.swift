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
import CoreLocation
import HealthKit

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
    
    var activeRun: Run!
    var healthStore: HKHealthStore!
    var configuration: HKWorkoutConfiguration!
    var session: HKWorkoutSession!
    var builder: HKLiveWorkoutBuilder!
    
    var runIsActive: Bool = false
    var isPaused: Bool = false
    var runStartTime: Date = Date()
    var elapsedTime: TimeInterval = 0
    var duration: TimeInterval = 0
    var timer: Timer = Timer()
    var timer5s: Timer = Timer()
    
    var currentRunPhase: RunPhase = .warmup
    var currentInterval = 0

    let synth = AVSpeechSynthesizer()
    let beginRunUtterance = AVSpeechUtterance(string: "Begin warmup")
    let pausingWorkoutUtterance = AVSpeechUtterance(string: "Pausing workout")
    let resumingWorkoutUtterance = AVSpeechUtterance(string: "Resuming workout")
    let workoutCompleteUtterance = AVSpeechUtterance(string: "Workout complete")
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error.localizedDescription)
        }
        
        synth.delegate = self
        
        if let sessionContext = context as? WorkoutSessionContext {
            healthStore = sessionContext.healthStore
            configuration = sessionContext.configuration
            
            do {
                session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
                builder = session.associatedWorkoutBuilder()
            } catch {
                dismiss()
                return
            }
            
            session.delegate = self
            builder.delegate = self
            
            builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,
                                                         workoutConfiguration: configuration)
            
            activeRun = sessionContext.run
            if let run = activeRun {
                if runIsActive {
                    configureViewForActiveRun(run: run)
                } else {
                    configureViewForPreRun(run: run)
                }
            }
            
        }
    }
    
    func configureViewForPreRun(run: Run) {
        idleGroup.setHidden(false)
        activeGroup.setHidden(true)
        
        runLabel.setText("\(run.runTitle)")
        walkLabel.setText("\(run.walkTitle)")
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
        
        session.startActivity(with: Date())
        builder.beginCollection(withStart: Date()) { (success, error) in
            if let err = error {
                print(err.localizedDescription)
            }
        }
        
        startTimer(duration: 300)
        
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
        if timeDelta > 5 {
            timer5s = Timer.scheduledTimer(timeInterval: timeDelta, target: self, selector: #selector(warningTime), userInfo: nil, repeats: false)
        }
        timeLabel.setDate(Date(timeIntervalSinceNow: timeDelta))
        timeLabel.start()
        pauseButton.setTitle("Pause")
    }
    
    @IBAction func pauseButtonPressed() {
        if isPaused {
            session.resume()
            startTimer(duration: duration)
            synth.speak(resumingWorkoutUtterance)
        } else {
            session.pause()
            isPaused = true
            synth.speak(pausingWorkoutUtterance)
            let paused = Date()
            elapsedTime += paused.timeIntervalSince(runStartTime)
            
            //stop watchkit timer on the screen
            timeLabel.stop()
            
            //stop the ticking of the internal timer
            timer.invalidate()
            timer5s.invalidate()
            
            //do whatever UI changes you need to
            pauseButton.setTitle("Resume")
        }
    }
    
    @IBAction func cancelButtonPressed() {
        runIsActive = false
        endRun()
    }
    
    @objc func warningTime() {
        WKInterfaceDevice.current().play(.notification)
    }
    
    @objc func timerDone() {
        switch currentRunPhase {
        case .warmup:
            currentRunPhase = .run
            titleLabel.setText("Run")
            let runUtterance = AVSpeechUtterance(string: "Run for \(activeRun!.runTitle)")
            synth.speak(runUtterance)
            elapsedTime = 0
            startTimer(duration: TimeInterval(activeRun!.run * 60))
        case .run:
            currentRunPhase = .walk
            titleLabel.setText("Walk")
            let walkUtterance = AVSpeechUtterance(string: "Walk for \(activeRun!.walkTitle)")
            synth.speak(walkUtterance)
            elapsedTime = 0
            startTimer(duration: TimeInterval(activeRun!.walk * 60))
        case .walk:
            currentInterval = currentInterval + 1
            if activeRun?.mode == RunMode.interval && currentInterval >= (activeRun?.repeatCount ?? 0) {
                endRun()
            } else {
                currentRunPhase = .run
                titleLabel.setText("Run")
                let runUtterance = AVSpeechUtterance(string: "Run for \(activeRun!.runTitle)")
                synth.speak(runUtterance)
                elapsedTime = 0
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
        timer5s.invalidate()
        synth.speak(workoutCompleteUtterance)
        session.end()
        popToRootController()
    }
}

extension RunInterfaceController: AVSpeechSynthesizerDelegate {
    
}

extension RunInterfaceController: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension RunInterfaceController: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        
    }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return // Nothing to do.
            }
            
            /// - Tag: GetStatistics
            let statistics = workoutBuilder.statistics(for: quantityType)
            switch quantityType {
            case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning):
                let meterUnit = HKUnit.meter()
                let value = statistics?.sumQuantity()?.doubleValue(for: meterUnit)
                let roundedValue = Double( round( 1 * value! ) / 1 )
                let miles = roundedValue * 0.000621371
                if activeRun.mode == .distance && Double(activeRun.mileTarget) >= miles {
                    endRun()
                }
            default:
                break
            }
        }
    }
}
