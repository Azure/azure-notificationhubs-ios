//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <UIKit/UIKit.h>
#import <WindowsAzureMessaging/WindowsAzureMessaging.h>
#import "AppVoIPMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface NotificationDetailsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;

@property (weak, nonatomic) AppVoIPMessage *notification;

@end

NS_ASSUME_NONNULL_END
