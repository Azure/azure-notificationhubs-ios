//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------


import SwiftUI
import WindowsAzureMessaging

struct SetupView: View {
    @State var tag: String = "";
    @State var tags: [String] = MSNotificationHub.getTags()
    @ObservedObject var installation: ObservableInstallation
    @State var userId: String = MSNotificationHub.getUserId()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Device Token:")
                .font(.headline)
                .padding(.leading)
            Text(installation.pushChannel)
                .font(.footnote)
                .foregroundColor(Color.gray)
                .padding([.leading, .bottom, .trailing])
            
            Text("Installation ID:")
                .font(.headline)
                .padding(.leading)
            Text(installation.installationId)
                .font(.footnote)
                .foregroundColor(Color.gray)
                .padding([.leading, .bottom, .trailing])
            
            Text("User ID:")
                .font(.headline)
                .padding(.leading)
            TextField("Set User ID", text: $userId, onEditingChanged: {focus in
                if(!focus) {
                    MSNotificationHub.setUserId(self.userId)
                }
            })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding([.leading, .bottom, .trailing])
            
            Text("Tags:")
                .font(.headline)
                .padding(.leading)
            TextField("Add new tag", text: $tag, onCommit: {
                if(self.tag != "") {
                    MSNotificationHub.addTag(self.tag)
                    self.tags.append(self.tag)
                    self.tag = ""
                }
            })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding([.leading, .bottom, .trailing])
            
            TagsList(tags: tags, onDelete: {
                $0.forEach({
                    MSNotificationHub.removeTag(self.tags.remove(at: $0));
                })
            })
            
            Spacer()
        }
    }
}

struct SetupView_Previews: PreviewProvider {
    static var previews: some View {
        SetupView(installation: ObservableInstallation(installationId: "<installationId>", pushChannel: "pushChannel"))
    }
}
