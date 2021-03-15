//
//  Health.swift
//  RunBuddy
//
//  Created by Chris Mills on 12/26/20.
//

import Foundation
import HealthKit
import WatchKit

protocol HealthDelegate {
    func onWalkingStatisticUpdated(miles: Double)
}

class Health: NSObject {
    static let shared = Health()
    let healthStore = HKHealthStore()
    let configuration: HKWorkoutConfiguration = HKWorkoutConfiguration()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    var delegate: HealthDelegate?
    
    private let typesToShare: Set = [ HKQuantityType.workoutType() ]
    private let typesToRead: Set = [ HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)! ]
    
    func requestAccess(completion: @escaping (Bool, Error?) -> Void) {
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead, completion: { (success, error) in
            if (success) {
                self.createSession()
            }
            completion(success, error)
        })
    }
    
    func createSession() {
        configuration.activityType = .running
        configuration.locationType = .outdoor
        do {
            self.session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
            session?.delegate = self
            builder?.delegate = self
            builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,
                                                         workoutConfiguration: configuration)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func begin() {
        session?.startActivity(with: Date())
        builder?.beginCollection(withStart: Date()) { (success, error) in
            if let err = error {
                print(err.localizedDescription)
            }
        }
    }
    
    func end() {
        session?.end()
    }
    
    func pause() {
        session?.pause()
    }
    
    func resume() {
        session?.resume()
    }
}

extension Health: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        if toState == .ended {
            builder?.endCollection(withEnd: Date()) { (success, error) in
                self.builder?.finishWorkout { (workout, error) in

                }
            }
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension Health: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        
    }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return // Nothing to do.
            }
            
            let statistics = workoutBuilder.statistics(for: quantityType)
            switch quantityType {
            case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning):
                let meterUnit = HKUnit.meter()
                let value = statistics?.sumQuantity()?.doubleValue(for: meterUnit)
                let roundedValue = Double( round( 1 * value! ) / 1 )
                let miles = roundedValue * 0.000621371
                delegate?.onWalkingStatisticUpdated(miles: miles)
            default:
                break
            }
        }
    }
}
