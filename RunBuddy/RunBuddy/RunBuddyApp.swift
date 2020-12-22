//
//  RunBuddyApp.swift
//  RunBuddy
//
//  Created by Richard Mills on 12/7/20.
//

import SwiftUI

@main
struct RunBuddyApp: App {
    @ObservedObject private var data = RunData()
    var body: some Scene {
        WindowGroup {
            ContentView(runs: $data.runs, selectedIndex: 0)
                .onAppear {
                    data.load()
                }
                .background(Color.black)
        }
    }
}
