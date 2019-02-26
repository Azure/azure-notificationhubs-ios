//
//  ViewController.swift
//  nhubsample
//
//  Created by TOYS on 2/25/19.
//  Copyright © 2019 Microsoft. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tagsTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var unregisterButton: UIButton!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Simple method to dismiss keyboard when user taps outside of the UITextField.
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tagsTextField.text = UserDefaults.standard.string(forKey: Constants.NHUserDefaultTags)
    }

    @IBAction func handleRegister(_ sender: Any) {
        // Save raw tags text in storage
        UserDefaults.standard.set(self.tagsTextField.text, forKey: Constants.NHUserDefaultTags)
        
        //
        // Delegate processing the register action to the app delegate.
        //
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.handleRegister()
    }
    @IBAction func handleUnregister(_ sender: Any) {
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.handleUnregister()
    }
    
}
