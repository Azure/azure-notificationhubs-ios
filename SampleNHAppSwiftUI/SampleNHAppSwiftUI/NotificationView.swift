//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

import SwiftUI
import WindowsAzureMessaging

struct NotificationView: View {
    var notification: MSNotificationHubMessage;
    
    var body: some View {
        VStack() {
            HStack {
                Text(notification.body ?? "<Body is missing>")
                    .font(.footnote)
                    .foregroundColor(Color.gray)
                    .padding([.leading, .bottom, .trailing])
                Spacer()
            }
            
            Spacer()
        }
        .navigationBarTitle(Text(notification.title ?? "<Title is missing>").font(.headline))
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView( notification: MSNotificationHubMessage())
    }
}
