//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <UIKit/UIKit.h>
#import <WindowsAzureMessaging/WindowsAzureMessaging.h>
#import "AppVoIPMessage.h"
#import "NotificationTableViewCell.h"
#import "NotificationDetailsViewController.h"

@interface NotificationsTableViewController : UITableViewController
@property (nonatomic) NSMutableArray<AppVoIPMessage *> *notifications;

-(void) addNotification:(AppVoIPMessage *) notification;
@end

