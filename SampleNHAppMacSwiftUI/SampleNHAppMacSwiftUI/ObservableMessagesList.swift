//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

import Foundation
import WindowsAzureMessaging

class ObservableMessagesList: ObservableObject {
    @Published var items = [MSNotificationHubMessage]()
    
    init(items: [MSNotificationHubMessage]){
        self.items = items
    }
}
