// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "NotificationDetailsViewController.h"

@interface NotificationDetailsViewController ()

@end

@implementation NotificationDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.summaryLabel.text = self.notification.title;
    self.detailsLabel.text = self.notification.message;
    
    [self.detailsLabel sizeToFit];
}

@end
