//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

import UIKit

class NotificationDetailsViewController: UIViewController {
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    
    var notification:MSNotificationHubMessage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        summaryLabel.text = notification.title
        detailsLabel.text = notification.body
        detailsLabel.sizeToFit()
    }
}
