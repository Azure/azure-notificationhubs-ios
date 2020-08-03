//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

import SwiftUI
import WindowsAzureMessaging

struct NotificationsList: View {
    @ObservedObject var notifications: ObservableMessagesList
    
    var body: some View {
        NavigationView {
            List {
                ForEach(notifications.items, id: \.self) { notification in
                    NavigationLink(destination: NotificationView(notification: notification)) {
                        Row(title: notification.title ?? notification.body ?? "row");
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationBarTitle(Text("Notifications"))
        }
    }
}

struct NotificationsList_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsList(notifications: ObservableMessagesList(items: [MSNotificationHubMessage()]))
    }
}
