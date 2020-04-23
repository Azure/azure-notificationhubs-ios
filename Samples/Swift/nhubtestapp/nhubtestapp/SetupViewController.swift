//
//  SetupViewController.swift
//  nhubtestapp
//
//  Created by Artem Egorov on 4/22/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var deviceTokenLabel: UILabel!
    @IBOutlet weak var installationIdLabel: UILabel!
    @IBOutlet weak var addNewTagTextField: UITextField!
    @IBOutlet weak var tagsTable: UITableView!
    
    var tags = ["tag1", "tag2", "veryveryveryveryveryveryveryveryverylongtag"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNewTagTextField.delegate = self
        tagsTable.delegate = self
        tagsTable.dataSource = self
        tagsTable.reloadData()
        
        deviceTokenLabel.text = "device-token"
        
        installationIdLabel.text = "installation-id"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        tags.append(textField.text!)
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
        
        cell.tagLabel.text = tags[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {

        tags.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tagsTable.reloadData()
      }
    }
    
}

