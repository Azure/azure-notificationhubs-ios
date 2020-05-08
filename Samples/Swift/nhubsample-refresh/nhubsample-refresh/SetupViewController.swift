//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

import UIKit

class SetupViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, MSNotificationHubDelegate {
    
    @IBOutlet weak var deviceTokenLabel: UILabel!
    @IBOutlet weak var installationIdLabel: UILabel!
    @IBOutlet weak var addNewTagTextField: UITextField!
    @IBOutlet weak var tagsTable: UITableView!
    
    var tags = MSNotificationHub.getTags()
    var notificationsTableView:NotificationsTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNewTagTextField.delegate = self
        tagsTable.delegate = self
        tagsTable.dataSource = self
        tagsTable.reloadData()
        
        deviceTokenLabel.text = MSNotificationHub.getInstallation().installationID
        installationIdLabel.text = MSNotificationHub.getInstallation().pushChannel
        
        notificationsTableView = (self.tabBarController?.viewControllers?[1] as! UINavigationController).viewControllers[0] as? NotificationsTableViewController
        
        MSNotificationHub.setDelegate(self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        MSNotificationHub.addTag(textField.text!)
        tags = MSNotificationHub.getTags()
        textField.text = ""
        tagsTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TagCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TagTableViewCell  else {
            fatalError("The dequeued cell is not an instance of TagCell.")
        }
        
        cell.tagLabel.text = tags[indexPath.row] as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {

        MSNotificationHub.removeTag((tags[indexPath.row] as? String)!)
        tags = MSNotificationHub.getTags()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tagsTable.reloadData()
      }
    }
    
    func notificationHub(_ notificationHub: MSNotificationHub!, didReceivePushNotification notification: MSNotificationHubMessage!) {
        NSLog("Received notification: %@; %@", notification.title ?? "<nil>", notification.message)
        notificationsTableView?.addNotification(notification);
        
        let alertController = UIAlertController(title: notification.title, message: notification.message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alertController, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            alertController.dismiss(animated: true, completion: nil)
        }
    }
    
}

