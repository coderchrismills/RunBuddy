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
        VStack(alignment: .center, spacing: 2.0) {
            HStack {
                run.icon
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .scaledToFit()
                    .padding(2)
                    .frame(maxWidth: 48, maxHeight: 48)
                Text("\(dayOfMonth)")
                    .font(.title2)
                    .fontWeight(.light)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    
            }
            
            switch run.type {
            case .run:
                Divider()
                
                HStack {
                    Text("Run:")
                        .font(.body)
                    Text("\(runTitle)")
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                }
                
                HStack {
                    Text("Walk:")
                        .font(.body)
                    Text("\(walkTitle)")
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                }
                
                HStack {
                    Text("Repeat:")
                        .font(.body)
                    Text("\(run.repeatCount)x")
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                }
            case .crossTrain:
                Text("Cross Train")
            case .rest:
                Text("Rest")
            }
            
        }
        .padding(8)
        .font(.body)
        .foregroundColor(Color.white)
        .background(run.color)
        .cornerRadius(12)
    }
}

struct RunCard_Previews: PreviewProvider {
    static var previews: some View {
        RunCard(run: .constant(Run.data[0]))
    }
}
