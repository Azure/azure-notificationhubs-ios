//
//  NotificationTableViewCell.h
//  nhubsample-refresh
//
//  Created by Artem Egorov on 4/24/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NotificationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *notificationSummaryLabel;

@end

NS_ASSUME_NONNULL_END
