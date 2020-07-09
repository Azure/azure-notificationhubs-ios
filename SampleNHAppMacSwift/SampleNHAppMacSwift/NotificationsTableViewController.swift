import Cocoa
import WindowsAzureMessaging

class NotificationsTableViewController: NSObject {
    var notifications = [MSNotificationHubMessage]()
    
    func addNotification(_ newNotification: MSNotificationHubMessage) {
        self.notifications.append(newNotification);
    }
}

extension NotificationsTableViewController : NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cell: NSTableCellView?
        
        let titleCellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "TitleNotificationCell")
        let bodyCellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "BodyNotificationCell")
        
        if (tableColumn == tableView.tableColumns[0]) {
            cell = tableView.makeView(withIdentifier:titleCellIdentifier, owner: nil) as? NSTableCellView
            cell?.textField?.stringValue = notifications[row].title ?? "<no title>"
        } else if (tableColumn == tableView.tableColumns[1]) {
            cell = tableView.makeView(withIdentifier:bodyCellIdentifier, owner: nil) as? NSTableCellView
            cell?.textField?.stringValue = notifications[row].body
        }
        
        return cell
    }
}

extension NotificationsTableViewController : NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return notifications.count;
    }
}
