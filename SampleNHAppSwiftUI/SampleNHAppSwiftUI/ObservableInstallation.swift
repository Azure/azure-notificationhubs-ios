//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

import Foundation
import WindowsAzureMessaging

class ObservableInstallation: ObservableObject {
    @Published var installationId: String
    @Published var pushChannel: String
    
    init(installationId: String, pushChannel: String) {
        self.installationId = installationId
        self.pushChannel = pushChannel
    }
}
