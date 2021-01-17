//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

import SwiftUI
import WindowsAzureMessaging

struct NotificationsList: View {
    @EnvironmentObject var notificationViewModel: NotificationViewModel

    var body: some View {
        List {
            ForEach(self.notificationViewModel.items, id: \.self) { notification in
                Row(title: notification.title ?? "<nil_title>", message: notification.body ?? "<nil_body>")
            }
        }
    }
}

struct NotificationsList_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsList()
            .environmentObject(NotificationViewModel())
    }
}

