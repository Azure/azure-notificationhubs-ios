//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

import SwiftUI

struct TagsList: View {
    @State private var selection: String? = nil
    var tags: [String]
    var onDelete: (String) -> Void
    
    var body: some View {
        List(selection: $selection) {
            ForEach(tags, id: \.self) {
                Row(title: $0);
            }
        }
        .onDeleteCommand(perform: {
            self.onDelete(self.selection!)
        })
    }
}

struct TagsList_Previews: PreviewProvider {
    static var previews: some View {
        TagsList(tags: ["tag1", "tag2"], onDelete: {_ in })
    }
}
