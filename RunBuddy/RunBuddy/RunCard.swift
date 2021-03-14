//
//  RunCard.swift
//  RunBuddy
//
//  Created by Chris Mills on 12/21/20.
//

import SwiftUI

struct RunCard: View {
    @Binding var run: Run

    var runTitle: String {
        let runSuffix = run.runInMinutes > 1 ? "s" : ""
        return "\(run.runInMinutes) Minute\(runSuffix)"
    }
    
    var walkTitle: String {
        let walkSuffix = run.walkInMinutes > 1 ? "s" : ""
        return "\(run.walkInMinutes) Minute\(walkSuffix)"
    }
    
    var dayOfMonth: String {
        return Calendar.autoupdatingCurrent.weekdaySymbols[run.day-1]
    }
    
    var body: some View {
        GeometryReader { metrics in
            VStack {
                VStack(spacing: 16) {
                    Text("Week \(run.week): \(dayOfMonth.localizedCapitalized)")
                        .font(.title)
                    Text("Run: \(runTitle)")
                    Text("Walk \(walkTitle)")
                    Text("Repeat: \(run.repeatCount)x")
                }
                .frame(width: metrics.size.width * 0.80, height: metrics.size.width * 0.80)
                .foregroundColor(Color.white)
                .background(run.color)
                .padding(.leading, metrics.size.width * 0.10)
            }
        }
    }
}

struct RunCard_Previews: PreviewProvider {
    static var previews: some View {
        RunCard(run: .constant(Run.data[0]))
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 5 - 44mm"))
    }
}
