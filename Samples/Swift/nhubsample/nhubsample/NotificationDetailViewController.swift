//
//  Copyright © 2018 Microsoft All rights reserved.
//  Licensed under the Apache License (2.0).
//

import UIKit

class NotificationDetailViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var bodyLabel: UILabel!
    
    var _userInfo: [String: Any]?
    
    init(_ userInfo: Any) {
        super.init(nibName: "NotificationDetail", bundle: nil)
        _userInfo = userInfo as? [String: Any]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func viewDidLayoutSubviews() {
        self.titleLabel.sizeToFit();
        self.bodyLabel.sizeToFit();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var title: String?
        var body: String?
    
        let aps = _userInfo?["aps"] as? [String: Any]
        let alertObject = aps?["alert"]
        if (alertObject != nil) {
            if let alertDict = alertObject as? [String: Any] {
                title = alertDict["title"] as? String
                body = alertDict["body"] as? String
            } else if let alertStr = alertObject as? String {
                body = alertStr
            } else {
                print("Unable to parse notification content. Unexpected format: \(String(describing: alertObject))");
            }
        }
        
        if (title == nil) {
            title = "<unset>"
        }
        
        if (body == nil) {
            body = "<unset>"
        }
        
        self.titleLabel.text = title
        self.bodyLabel.text = body
    }
    
    @IBAction func handleDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
