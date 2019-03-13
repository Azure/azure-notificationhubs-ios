//
//  Copyright © 2018 Microsoft All rights reserved.
//  Licensed under the Apache License (2.0).
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
    @IBOutlet weak var tagsTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var unregisterButton: UIButton!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Simple method to dismiss keyboard when user taps outside of the UITextField.
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
}

private extension ViewController {
    
    func setupUI() {
        tagsTextField.text = UserDefaults.standard.string(forKey: Constants.NHUserDefaultTags)
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    @IBAction func handleRegister(_ sender: Any) {
        // Save raw tags text in storage
        UserDefaults.standard.set(tagsTextField.text, forKey: Constants.NHUserDefaultTags)
        
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                granted, error in
                if (error != nil) {
                    print("Error requesting for authorization:");
                }
                print("Permission granted: \(granted)")
                guard granted else { return }
                self.getNotificationSettings()
        }
    }
    
    @IBAction func handleUnregister(_ sender: Any) {
        let hub = getNotificationHub()
        hub.unregisterNative { error in
            if (error != nil) {
                print("Error unregistering for push: \(error.debugDescription)");
            } else {
                showAlert("Unregistered", withTitle: "Registration Status")
            }
        }
    }
}
