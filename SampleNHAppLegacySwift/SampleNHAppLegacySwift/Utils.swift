//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

import Foundation
import UIKit
import WindowsAzureMessaging

struct Constants {
    static let NHInfoConnectionString = "NotificationHubConnectionString";
    static let NHInfoHubName = "NotificationHubName";
    static let NHUserDefaultTags = "notification_tags";
}

func getNotificationHub() -> SBNotificationHub {    
    let path = Bundle.main.path(forResource: "DevSettings", ofType: "plist")
    let configValues = NSDictionary(contentsOfFile: path!)
    let connectionString = configValues?["CONNECTION_STRING"] as? String
    let hubName = configValues?["HUB_NAME"] as? String
            
    return SBNotificationHub.init(connectionString: connectionString, notificationHubPath: hubName)
}

func showAlert(_ message: String, withTitle title: String = "Alert") {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
}
