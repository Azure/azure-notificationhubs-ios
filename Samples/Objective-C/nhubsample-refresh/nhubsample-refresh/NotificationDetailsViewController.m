//
//  NotificationDetailsViewController.m
//  nhubsample-refresh
//
//  Created by Artem Egorov on 4/24/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

#import "NotificationDetailsViewController.h"

@interface NotificationDetailsViewController ()

@end

@implementation NotificationDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.summaryLabel.text = self.notification;
    self.detailsLabel.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
    [self.detailsLabel sizeToFit];
}

@end
