//
//  SampleNHAppSwiftUI2App.swift
//  SampleNHAppSwiftUI2
//
//  Created by Hyounwoo Sung on 2021/01/16.
//

import SwiftUI
import UserNotifications
import WindowsAzureMessaging

@main
struct SampleNHAppSwiftUI2App: App {
    @StateObject private var notificationViewModel = NotificationViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationViewModel)
        }
        .onChange(of: scenePhase) { (newScenePhase) in
            switch newScenePhase {
            case .active:
                print("scene is now active!")
            case .inactive:
                print("scene is now inactive!")
            case .background:
                print("scene is now in the background!")
            @unknown default:
                print("Apple must have added something new!")
            }
        }
    }
}
