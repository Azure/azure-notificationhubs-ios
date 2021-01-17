//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

import SwiftUI

struct Row: View {
    var title: String = "<nil_title>"
    var message: String = ""

    var body: some View {
        HStack {
            Text(title)
            .foregroundColor(Color.gray)
            Text(message)
            .foregroundColor(Color.gray)
            Spacer()
        }
    }
}

struct Row_Previews: PreviewProvider {
    static var previews: some View {
        Row()
            .previewLayout(.fixed(width: 300, height: 70))
    }
}

