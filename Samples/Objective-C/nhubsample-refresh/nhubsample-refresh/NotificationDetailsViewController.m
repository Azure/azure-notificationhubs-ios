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
    
    self.summaryLabel.text = self.notification.title;
    self.detailsLabel.text = self.notification.message;
    
    [self.detailsLabel sizeToFit];
}

@end
