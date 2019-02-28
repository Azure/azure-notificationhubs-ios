//
//  Copyright © 2018 Microsoft All rights reserved.
//  Licensed under the Apache License (2.0).
//

import Foundation
import UIKit

struct Constants {
    static let NHInfoConnectionString = "NotificationHubConnectionString";
    static let NHInfoHubName = "NotificationHubName";
    static let NHUserDefaultTags = "notification_tags";
}

func getNotificationHub() -> SBNotificationHub {
    let NHubName = Bundle.main.object(forInfoDictionaryKey: Constants.NHInfoHubName) as? String
    let NHubConnectionString = Bundle.main.object(forInfoDictionaryKey: Constants.NHInfoConnectionString) as? String
    
    return SBNotificationHub.init(connectionString: NHubConnectionString, notificationHubPath: NHubName)
}

func showAlert(_ message: String, withTitle title: String = "Alert") {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
}
