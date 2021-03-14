//
//  RunSession.swift
//  RunBuddy
//
//  Created by Chris Mills on 3/12/21.
//

import Foundation

class RunSession {
    var health:Health = Health()
    var activeRun: Run?
    
    init() {
        health.delegate = self
    }
    
    func startRun(run: Run) {
        activeRun = run
    }
    
    func endRun() {
        
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
