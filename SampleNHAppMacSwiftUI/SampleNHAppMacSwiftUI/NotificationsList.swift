//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

import SwiftUI
import WindowsAzureMessaging

struct NotificationsList: View {
    @ObservedObject var notifications: ObservableMessagesList
    
    var body: some View {
        List {
            ForEach(notifications.items, id: \.self) { notification in
                Row(title: notification.title ?? "<nil_title>", message: notification.body ?? "<nil_body>")
            }
        }
    }
}

struct NotificationsList_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsList(notifications: ObservableMessagesList(items: [MSNotificationHubMessage()]))
    }
}
