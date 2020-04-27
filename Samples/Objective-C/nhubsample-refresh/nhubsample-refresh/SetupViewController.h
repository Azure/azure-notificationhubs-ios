// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <UIKit/UIKit.h>
#import <WindowsAzureMessaging/WindowsAzureMessaging.h>
#import "TagTableViewCell.h"

@interface SetupViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *deviceTokenLabel;
@property (weak, nonatomic) IBOutlet UILabel *installationIdLabel;
@property (weak, nonatomic) IBOutlet UITextField *addNewTagTextField;
@property (weak, nonatomic) IBOutlet UITableView *tagsTable;

@property (weak, nonatomic) NSArray<NSString *> *tags;

@end

