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
        return "\(run.runInMinutes) Min"
    }
    
    var walkTitle: String {
        return "\(run.walkInMinutes) Min"
    }
    
    var dayOfMonth: String {
        return Calendar.autoupdatingCurrent.weekdaySymbols[run.day-1]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2.0) {
            Text("Week \(run.week): \(dayOfMonth)")
                .font(.caption2)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            switch run.type {
            case .run:
                HStack() {
                    Image("run")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 22)
                    
                    Text("\(runTitle)")
                }.font(.body)
                
                HStack {
                    Image("walk")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 22)
                    Text("\(walkTitle)")
                }.font(.body)
                
                HStack {
                    if run.repeatCount > 0 {
                        Image(systemName: "stopwatch.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 22)
                        Text("\(run.repeatCount)x")
                    } else {
                        Image(systemName: "map.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 22)
                        Text("\(run.mileTarget) miles")
                    }
                    
                }.font(.body)
            case .crossTrain:
                Text("Cross Train")
                    .font(.body)
            case .rest:
                Text("Rest")
                    .font(.body)
            }
            
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4.0)
        .padding()
        .foregroundColor(Color.white)
        .background(run.color)
        .cornerRadius(8)
    }
}

struct RunCard_Previews: PreviewProvider {
    static var previews: some View {
        RunCard(run: .constant(Run.data[1]))
    }
}
