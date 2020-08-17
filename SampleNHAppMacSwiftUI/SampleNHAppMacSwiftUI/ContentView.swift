//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

import SwiftUI
import WindowsAzureMessaging

struct ContentView: View {
    @State var tag: String = ""
    @State var tags: [String] = MSNotificationHub.getTags()
    @State var userId: String = MSNotificationHub.getUserId()
    
    @ObservedObject var notifications: ObservableMessagesList
    @ObservedObject var installation: ObservableInstallation
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                Text("Device Token:")
                    .font(.headline)
                Text(installation.pushChannel)
                    .font(.footnote)
                    .foregroundColor(Color.gray)
                    .padding(.bottom)
            }
            
            Group {
                Text("Installation ID:")
                    .font(.headline)
                Text(installation.installationId)
                    .font(.footnote)
                    .foregroundColor(Color.gray)
                    .padding(.bottom)
            }
            
            Group {
                Text("User ID:")
                    .font(.headline)
                TextField("Set User ID", text: $userId, onEditingChanged: {focus in
                    if(!focus) {
                        MSNotificationHub.setUserId(self.userId)
                    }
                })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Group {
                Text("Tags:")
                    .font(.headline)
                TextField("Add new tag", text: $tag, onCommit: {
                    if(self.tag != "") {
                        MSNotificationHub.addTag(self.tag)
                        self.tags.append(self.tag)
                        self.tag = ""
                    }
                })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TagsList(tags: tags, onDelete: {
                    if let idx = self.tags.firstIndex(of: $0) {
                        self.tags.remove(at: idx)
                        MSNotificationHub.removeTag($0);
                    }
                })
            }
            
            Group {
                Text("Notifications:")
                    .font(.headline)
                NotificationsList(notifications: notifications)
            }
            
            Spacer()
        }
        .padding()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(notifications: ObservableMessagesList(items: []), installation: ObservableInstallation(installationId: "<installationId>", pushChannel: "<pushChannel>"))
    }
}
