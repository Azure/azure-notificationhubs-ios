//
//  ViewController.swift
//  SampleNHAppMacSwift
//
//  Created by Matthew Podwysocki on 6/30/20.
//  Copyright © 2020 Matthew Podwysocki. All rights reserved.
//

import Cocoa
import WindowsAzureMessaging
import Carbon.HIToolbox

class ViewController: NSViewController, NSTextFieldDelegate, MSNotificationHubDelegate {

    @IBOutlet weak var deviceTokenTextField: NSTextField!
    @IBOutlet weak var installationIdTextField: NSTextField!
    @IBOutlet weak var tagsTextField: NSTextField!
    @IBOutlet weak var tagsTable: NSTableView!
    @IBOutlet weak var notificationsTable: NSTableView!
    
    var tagsTableViewController: TagsTableViewController!
    var notificationsTableViewController: NotificationsTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MSNotificationHub.setDelegate(self)
        self.tagsTextField.delegate = self
        
        deviceTokenTextField.stringValue = MSNotificationHub.getPushChannel()
        installationIdTextField.stringValue = MSNotificationHub.getInstallationId()
        
        self.tagsTableViewController = TagsTableViewController(data: MSNotificationHub.getTags())
        self.tagsTable.delegate = self.tagsTableViewController
        self.tagsTable.dataSource = self.tagsTableViewController
        
        self.notificationsTableViewController = NotificationsTableViewController()
        self.notificationsTable.delegate = self.notificationsTableViewController
        self.notificationsTable.dataSource = self.notificationsTableViewController
        
        self.tagsTable.reloadData()
        self.notificationsTable.reloadData()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            let tag = self.tagsTextField.stringValue;
            
            if (tag != "") {
                MSNotificationHub.addTag(tag)
                self.tagsTextField.stringValue = ""
            }
            
            self.tagsTableViewController.addTags(newTags: MSNotificationHub.getTags())
            self.tagsTable.reloadData()
            
            return true
        }

        return false
    }
    
    override func keyDown(with event: NSEvent) {
        if(!event.modifierFlags.isEmpty) {
            if (event.keyCode == kVK_ForwardDelete || event.keyCode == kVK_Delete) {
                removeSelectedTags()
            }
            super.keyDown(with: event)
        }
    }
    
    func removeSelectedTags() {
        let selectedRow = self.tagsTable.selectedRow
        if (selectedRow >= 0) {
            if let cell = self.tagsTable.view(atColumn: 0, row: selectedRow, makeIfNecessary: true) as? NSTableCellView {
                let tagForRemoving = cell.textField?.stringValue ?? ""
                MSNotificationHub.removeTag(tagForRemoving)
                self.tagsTableViewController.addTags(newTags: MSNotificationHub.getTags())
                self.tagsTable.reloadData()
            }
        }
    }
    
    func notificationHub(_ notificationHub: MSNotificationHub!, didReceivePushNotification notification: MSNotificationHubMessage!) {
        NSLog("Received notification: %@; %@", notification.title ?? "<nil>", notification.body)
        self.notificationsTableViewController.addNotification(notification)
        self.notificationsTable.reloadData()
    }
}

