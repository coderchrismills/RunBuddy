//
//  RunBuddyApp.swift
//  RunBuddy WatchKit Extension
//
//  Created by Richard Mills on 12/7/20.
//

import SwiftUI

@main
struct RunBuddyApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
