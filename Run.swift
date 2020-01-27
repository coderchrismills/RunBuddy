//
//  Run.swift
//  RunBuddy
//
//  Created by Richard Mills on 1/25/20.
//  Copyright © 2020 Lazy Gardener. All rights reserved.
//

import UIKit

enum RunMode {
    case interval
    case distance
}

enum RunPhase {
    case warmup
    case run
    case walk
    case done
}

struct Run {
    let week: Int
    let day: Int
    let run: Int
    let walk: Int
    let repeatCount: Int
    let mileTarget: Int
    
    var color: UIColor {
        if day == 1 || day == 3 || day == 6 {
            return .run
        } else if day == 2 || day == 4 {
            return .crossTrain
        }
        return .rest
    }
    
    var title: String {
        if day == 1 || day == 3 || day == 6 {
            return "Run!"
        } else if day == 2 || day == 4 {
            return "XT"
        }
        return "Rest"
    }
    
    var mode: RunMode {
        return (repeatCount > 0) ? .interval : .distance
    }
    
    func toJSON() -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .withoutEscapingSlashes)
            if let jsonString = String(data: jsonData, encoding: .ascii) {
                return jsonString
            }
            return ""
        } catch {
            print(error.localizedDescription)
        }
        return ""
    }
    
    init(dict: Dictionary<String, Any>) {
        self.week = dict["week"] as? Int ?? 0
        self.day = dict["day"] as? Int ?? 0
        self.run = dict["run"] as? Int ?? 0
        self.walk = dict["walk"] as? Int ?? 0
        self.repeatCount = dict["repeatCount"] as? Int ?? 0
        self.mileTarget = dict["mileTarget"] as? Int ?? 0
    }

    static func getAllRuns() -> [Run] {
        var runs: [Run] = []
        if let path = Bundle.main.path(forResource: "run", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let runsJson = jsonResult["runs"] as? [Any] {
                    for runJson in runsJson {
                        if let runDictionary = runJson as? Dictionary<String, AnyObject> {
                            let run = Run(dict: runDictionary)
                            runs.append(run)
                        }
                    }
                }
            } catch {
                // handle error
                print(error.localizedDescription)
            }
        }
        return runs
    }
}
