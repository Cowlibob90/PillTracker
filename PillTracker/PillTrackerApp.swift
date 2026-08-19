//
//  PillTrackerApp.swift
//  PillTracker
//
//  Created by P06 on 13/08/26.
//

import SwiftUI

@main
struct PillTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(){
                    NotificationManager.instance.requestAuthorization()
                }
        }
    }
}
