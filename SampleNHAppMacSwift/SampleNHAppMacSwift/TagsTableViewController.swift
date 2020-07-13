//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

import Cocoa

class TagsTableViewController: NSObject {
    var tags = [String]()
    
    init(data : Array<String>) {
        super.init()
        self.addTags(newTags: data)
    }
    
    func addTags(newTags: Array<String>) {
        self.tags = newTags
    }
}

extension TagsTableViewController : NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "TagsCellID")
        if let cell = tableView.makeView(withIdentifier:cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = tags[row]
            return cell
        } else {
            return nil
        }
    }
}

extension TagsTableViewController : NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tags.count;
    }
}
