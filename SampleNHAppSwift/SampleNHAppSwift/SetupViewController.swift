//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

import UIKit

class SetupViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var deviceTokenLabel: UILabel!
    @IBOutlet weak var installationIdLabel: UILabel!
    @IBOutlet weak var addNewTagTextField: UITextField!
    @IBOutlet weak var tagsTable: UITableView!
    @IBOutlet weak var userId: UITextField!
    
    var tags = MSNotificationHub.getTags()
    var notificationsTableView:NotificationsTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNewTagTextField.delegate = self
        tagsTable.delegate = self
        tagsTable.dataSource = self
        tagsTable.reloadData()
        userId.delegate = self
        
        deviceTokenLabel.text = MSNotificationHub.getPushChannel()
        installationIdLabel.text = MSNotificationHub.getInstallationId()
        userId.text = MSNotificationHub.getUserId()
        
        notificationsTableView = (self.tabBarController?.viewControllers?[1] as! UINavigationController).viewControllers[0] as? NotificationsTableViewController
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceivePushNotification), name: Notification.Name("MessageReceived"), object: nil);
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("MessageReceived"), object: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField.tag == 0) {
            MSNotificationHub.setUserId(textField.text!)
        } else if (textField.text != "") {
            MSNotificationHub.addTag(textField.text!)
            tags = MSNotificationHub.getTags()
            textField.text = ""
            tagsTable.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TagCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TagTableViewCell  else {
            fatalError("The dequeued cell is not an instance of TagCell.")
        }
        
        cell.tagLabel.text = tags[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {

        MSNotificationHub.removeTag(tags[indexPath.row])
        tags = MSNotificationHub.getTags()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tagsTable.reloadData()
      }
    }
    
    @objc func didReceivePushNotification(notification: Notification) {
        let message = notification.userInfo!["message"] as! MSNotificationHubMessage;
        NSLog("Received notification: %@; %@", message.title ?? "<nil>", message.body)
        notificationsTableView?.addNotification(message);
        
        let alertController = UIAlertController(title: message.title, message: message.body, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alertController, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            alertController.dismiss(animated: true, completion: nil)
        }
    }
    
}

