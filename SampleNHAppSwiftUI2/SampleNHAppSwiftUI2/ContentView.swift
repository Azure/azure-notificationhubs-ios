//
//  ContentView.swift
//  SampleNHAppSwiftUI2
//
//  Created by Hyounwoo Sung on 2021/01/16.
//

import SwiftUI
import WindowsAzureMessaging

struct ContentView: View {
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @State private var showingAlert = false
    @State var notification: MSNotificationHubMessage = MSNotificationHubMessage()
    @State private var selection = 0


    var body: some View {
        TabView(selection: $selection){
            SetupView()
                .tabItem {
                    VStack {
                        Image(systemName: "wrench.fill")
                        Text("Setup")
                    }
                }
                .tag(0)
            NotificationsList()
                .tabItem {
                    VStack {
                        Image(systemName: "tray.fill")
                        Text("Notifications")
                    }
                }
                .tag(1)
        }
        .onReceive(self.notificationViewModel.messageReceived) { (notification) in
            self.didReceivePushNotification(notification: notification, messageTapped: false)
        }
        .onReceive(self.notificationViewModel.messageTapped) { (notification) in
            self.didReceivePushNotification(notification: notification, messageTapped: true)
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(self.notification.title ?? "Important message"), message: Text(self.notification.body ?? "Wear sunscreen"), dismissButton: .default(Text("Got it!")))
        }
        .environmentObject(notificationViewModel)
    }

    func didReceivePushNotification(notification: Notification, messageTapped: Bool) {
        let message = notification.userInfo!["message"] as! MSNotificationHubMessage
        NSLog("Received notification: %@; %@", message.title ?? "<nil>", message.body)

        // Assign the latest notification to self.notification.
        self.notification = message

        // Display Alert if message is tapped from background.
        if messageTapped {
            self.showingAlert = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(NotificationViewModel())
    }
}
