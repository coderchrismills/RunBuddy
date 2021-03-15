//
//  RunSession.swift
//  RunBuddy
//
//  Created by Chris Mills on 3/12/21.
//

import Foundation
import WatchKit
import AVFoundation
import SwiftUI
import Combine

class RunSession: ObservableObject {
    enum RunTimerMode {
        case running
        case stopped
        case paused
    }
    
    var health:Health = Health()
    var activeRun: Run?
    
    var isRunning: Bool = false
    var duration: TimeInterval = 0

    var cancellableTimer: Cancellable?
    var accumulatedTime: Int = 0
    var start: Date = Date()
    var elapsedSeconds: Int = 0
    var hasWarningNotified = false
    
    var currentRunPhase = RunPhase.warmup
    var currentInterval = 0
    
    let synth = AVSpeechSynthesizer()
    let beginRunUtterance = AVSpeechUtterance(string: "Begin warmup")
    let pausingWorkoutUtterance = AVSpeechUtterance(string: "Pausing workout")
    let resumingWorkoutUtterance = AVSpeechUtterance(string: "Resuming workout")
    let workoutCompleteUtterance = AVSpeechUtterance(string: "Workout complete")
    
    @Published var timeRemaining = 0.0
    @Published var mode: RunTimerMode = .stopped
    
    init() {
        health.delegate = self
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func startWarmup() {
        print("Starting warmup")
        currentRunPhase = .warmup
        self.duration = 20
        setupTimer()
        isRunning = true
        health.createSession()
        health.begin()
        synth.speak(beginRunUtterance)
    }
    
    func startWorkout(duration: TimeInterval) {
        print("Starting workout \(self.currentRunPhase): \(duration)")
        self.duration = duration
        setupTimer()
        isRunning = true
    }
    
    func togglePause() {
        print("togglePause")
        if isRunning {
            pauseWorkout()
        } else {
            resumeWorkout()
        }
    }
    
    func pauseWorkout() {
        print("pausingWorkout")
        health.pause()
        mode = .paused
        cancellableTimer?.cancel()
        accumulatedTime = elapsedSeconds
        isRunning = false
        synth.speak(pausingWorkoutUtterance)
    }
    
    func resumeWorkout() {
        print("resumingWorkout")
        health.resume()
        setupTimer()
        mode = .running
        isRunning = true
        synth.speak(resumingWorkoutUtterance)
    }
    
    func endRun() {
        print("ending workout")
        currentRunPhase = .done
        cancellableTimer?.cancel()
        health.end()
        mode = .stopped
        synth.speak(workoutCompleteUtterance)
    }
    
    func setupTimer() {
        print("setupTimer \(self.duration)")
        self.start = Date()
        self.timeRemaining = self.duration
        cancellableTimer?.cancel()
        
        cancellableTimer = Timer.publish(every: 0.1, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.elapsedSeconds = self.incrementElapsedTime()
                self.timeRemaining = self.duration - Double(self.elapsedSeconds)
                if (self.timeRemaining < 5.0 && !self.hasWarningNotified) {
                    self.hasWarningNotified = true
                    WKInterfaceDevice.current().play(.notification)
                }
                if (self.timeRemaining <= 0.0) {
                    self.timerDone()
                }
            }
    }

    func incrementElapsedTime() -> Int {
        let runningTime: Int = Int(-1 * (self.start.timeIntervalSinceNow))
        return self.accumulatedTime + runningTime
    }

    // TODO: Move speach to own file that listens for notifies
    @objc func timerDone() {
        guard let run = activeRun else { return }
        
        print("Timer done")
        
        let runTime = run.runInMinutes
        let walkTime = run.walkInMinutes
        let repeateCount = run.repeatCount
        
        let runSuffix = runTime > 1 ? "s" : ""
        let walkSuffix = walkTime > 1 ? "s" : ""
        let runTitle =  "\(runTime) Minute\(runSuffix)"
        let walkTitle =  "\(walkTime) Minute\(walkSuffix)"
        
        hasWarningNotified = false
        accumulatedTime = 0
        elapsedSeconds = 0
        
        switch currentRunPhase {
        case .warmup:
            currentRunPhase = .run
            let runUtterance = AVSpeechUtterance(string: "Run for \(runTitle)")
            synth.speak(runUtterance)
            startWorkout(duration: TimeInterval(runTime * 60))
        case .run:
            currentRunPhase = .walk
            let walkUtterance = AVSpeechUtterance(string: "Walk for \(walkTitle)")
            synth.speak(walkUtterance)
            startWorkout(duration: TimeInterval(walkTime * 60))
        case .walk:
            currentInterval = currentInterval + 1
            if run.mode == .interval && currentInterval >= repeateCount {
                endRun()
            } else {
                currentRunPhase = .run
                let runUtterance = AVSpeechUtterance(string: "Run for \(runTitle)")
                synth.speak(runUtterance)
                startWorkout(duration: TimeInterval(runTime * 60))
            }
        case .done:
            currentRunPhase = .done
        }
    }
}

extension RunSession: HealthDelegate {
    func onWalkingStatisticUpdated(miles: Double) {
        guard let run = activeRun else { return }
        if run.mode == .distance && Double(run.mileTarget) >= miles {
             endRun()
        }
    }
}
