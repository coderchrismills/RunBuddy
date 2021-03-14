//
//  RunBuddyApp.swift
//  RunBuddy WatchKit Extension
//
//  Created by Richard Mills on 12/7/20.
//

import SwiftUI

@main
struct RunBuddyApp: App {
    @ObservedObject private var data = RunData()
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView(runs: $data.runs, selectedIndex: 0)
                    .onAppear {
                        data.load()
                    }
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
