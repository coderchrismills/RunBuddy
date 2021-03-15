//
//  RunBuddyWatchApp.swift
//  RunBuddyWatch WatchKit Extension
//
//  Created by Chris Mills on 3/12/21.
//

import SwiftUI

@main
struct RunBuddyWatchApp: App {
    @ObservedObject private var data = RunData()
    var runSession = RunSession()
    
    var health: Health = Health()
    var body: some Scene {
        WindowGroup {
            ContentView(runs: $data.runs, selectedIndex: 0)
                .background(Color.black.edgesIgnoringSafeArea(.all))
                .onAppear {
                    data.load()
                    health.requestAccess() { success, error in
                    }
                }
                .environmentObject(runSession)
        }
    }
}
