//
//  NotificationsList.swift
//  SampleNHAppSwiftUI2
//
//  Created by Hyounwoo Sung on 2021/01/16.
//

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

