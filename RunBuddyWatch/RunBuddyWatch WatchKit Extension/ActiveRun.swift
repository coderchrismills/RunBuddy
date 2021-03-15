//
//  ActiveRun.swift
//  RunBuddy
//
//  Created by Chris Mills on 12/21/20.
//

import SwiftUI

struct ActiveRun: View {
    @Binding var run: Run
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var runSession: RunSession
    
    private func timeRemainingString(timeInSeconds: Binding<Double>) -> String {
        let timeInSecondsInt = Int(timeInSeconds.wrappedValue)
        let minute = (timeInSecondsInt % 3600) / 60
        let seconds = timeInSecondsInt % 60
        var secondPrefix = ""
        if seconds < 10 {
            secondPrefix = "0"
        }
        return "\(minute):\(secondPrefix)\(seconds)"
    }

    var body: some View {
        VStack(alignment: .center) {
            Text("\(timeRemainingString(timeInSeconds: $runSession.timeRemaining))")
                .font(.title)
                .padding(.bottom)
            Spacer()
            Button(action: toggleRunState) {
                if runSession.isRunning {
                    Text("Pause")
                } else {
                    Text("Start")
                }
            }
            .font(.title2)
            .foregroundColor(Color.white)
            .buttonStyle(BorderedButtonStyle(tint: Color.accent.opacity(255)))
            
            Button(action: endRun) {
                Text("End Run")
            }
            .font(.title2)
            .foregroundColor(Color.white)
            .buttonStyle(BorderedButtonStyle(tint: Color.red.opacity(255)))
        }
        .onAppear {
            runSession.activeRun = run
            runSession.startWarmup()
        }
    }
    
    private func toggleRunState() {
        runSession.togglePause()
    }
    
    private func endRun() {
        runSession.endRun()
        presentationMode.wrappedValue.dismiss()
    }
}

struct ActiveRun_Previews: PreviewProvider {
    static var previews: some View {
        ActiveRun(run: .constant(Run.data[0])).environmentObject(RunSession())
    }
}
