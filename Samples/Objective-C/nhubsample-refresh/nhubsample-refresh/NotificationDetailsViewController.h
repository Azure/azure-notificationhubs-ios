//
//  NotificationDetailsViewController.h
//  nhubsample-refresh
//
//  Created by Artem Egorov on 4/24/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WindowsAzureMessaging/WindowsAzureMessaging.h>

NS_ASSUME_NONNULL_BEGIN

@interface NotificationDetailsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;

@property (weak, nonatomic) MSNotificationHubMessage *notification;

@end

NS_ASSUME_NONNULL_END
