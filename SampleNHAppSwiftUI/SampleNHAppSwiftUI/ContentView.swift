//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------


import SwiftUI
import WindowsAzureMessaging

struct ContentView: View {
    @State private var selection = 0
    @ObservedObject var notifications: ObservableMessagesList
    @ObservedObject var installation: ObservableInstallation
    
    var body: some View {
        TabView(selection: $selection){
            SetupView(installation: installation)
                .tabItem {
                    VStack {
                        Image(systemName: "wrench.fill")
                        Text("Setup")
                    }
                }
                .tag(0)
            NotificationsList(notifications: notifications)
                .tabItem {
                    VStack {
                        Image(systemName: "tray.fill")
                        Text("Notifications")
                    }
                }
                .tag(1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(notifications: ObservableMessagesList(items: []), installation: ObservableInstallation(installationId: "<installationId>", pushChannel: "<pushChannel>"))
    }
}
