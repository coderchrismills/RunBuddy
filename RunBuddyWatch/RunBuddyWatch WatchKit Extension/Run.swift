//
//  Run.swift
//  RunBuddy
//
//  Created by Richard Mills on 1/25/20.
//  Copyright © 2020 Lazy Gardener. All rights reserved.
//

import SwiftUI

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

enum RunDayType {
    case run
    case crossTrain
    case rest
}

struct Run: Identifiable, Codable {
    let id: UUID
    let week: Int
    let day: Int
    let runInMinutes: Int
    let walkInMinutes: Int
    let repeatCount: Int
    let mileTarget: Int
    
    var color: Color {
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
    
    var type: RunDayType {
        if day == 1 || day == 3 || day == 6 {
            return .run
        } else if day == 2 || day == 4 {
            return .crossTrain
        }
        return .rest
    }
    
    var mode: RunMode {
        return (repeatCount > 0) ? .interval : .distance
    }
    
    var icon: Image {
        switch self.type {
        case .run:
            return Image(systemName: "figure.walk")
        case .crossTrain:
            return Image(systemName: "bicycle")
        case .rest:
            return Image(systemName: "moon.zzz.fill")
        }
    }
    
    var isRunDay: Bool {
        return self.type == .run
    }
    
    init(id: UUID = UUID(), week: Int, day: Int, runInMinutes: Int, walkInMinutes: Int, repeatCount: Int, mileTarget: Int) {
        self.id = id
        self.week = week
        self.day = day
        self.runInMinutes = runInMinutes
        self.walkInMinutes = walkInMinutes
        self.repeatCount = repeatCount
        self.mileTarget = mileTarget
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.week = try container.decodeIfPresent(Int.self, forKey: .week) ?? 0
        self.day = try container.decodeIfPresent(Int.self, forKey: .day) ?? 0
        self.runInMinutes = try container.decodeIfPresent(Int.self, forKey: .runInMinutes) ?? 0
        self.walkInMinutes = try container.decodeIfPresent(Int.self, forKey: .walkInMinutes) ?? 0
        self.repeatCount = try container.decodeIfPresent(Int.self, forKey: .repeatCount) ?? 0
        self.mileTarget = try container.decodeIfPresent(Int.self, forKey: .mileTarget) ?? 0
    }
}

extension Run {
    static var data: [Run] {
        [
            Run(week: 1, day: 1, runInMinutes: 1, walkInMinutes: 2, repeatCount: 10, mileTarget: 0),
            Run(week: 1, day: 2, runInMinutes: 0, walkInMinutes: 0, repeatCount: 0, mileTarget: 0),
            Run(week: 1, day: 3, runInMinutes: 1, walkInMinutes: 2, repeatCount: 10, mileTarget: 0),
            Run(week: 1, day: 4, runInMinutes: 0, walkInMinutes: 0, repeatCount: 0, mileTarget: 0),
            Run(week: 1, day: 5, runInMinutes: 0, walkInMinutes: 0, repeatCount: 0, mileTarget: 0),
            Run(week: 1, day: 6, runInMinutes: 1, walkInMinutes: 2, repeatCount: 0, mileTarget: 3)
        ]
    }
}
extension Run {
    struct Data {
        var week: Int = 0
        var day: Int = 0
        var runTimeInMinutes: Int = 0
        var walkTimeInMinutes: Int = 0
        var repeateCount: Int = 0
        var mileTarget: Int = 0
    }
    
    var data: Data {
        return Data(week: week, day: day, runTimeInMinutes: runInMinutes, walkTimeInMinutes: walkInMinutes, repeateCount: repeatCount, mileTarget: mileTarget)
    }
}
