//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "NotificationDetailViewController.h"

@interface NotificationDetailViewController ()

@end

@implementation NotificationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *title = nil;
    NSString *body = nil;
    
    NSDictionary *aps = [_userInfo valueForKey:@"aps"];
    NSObject *alertObject = [aps valueForKey:@"alert"];
    if (alertObject != nil) {
        if ([alertObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *alertDict = (NSDictionary *)alertObject;
            title = [alertDict valueForKey:@"title"];
            body = [alertObject valueForKey:@"body"];
        } else if ([alertObject isKindOfClass:[NSString class]]) {
            body = (NSString *)alertObject;
        } else {
            NSLog(@"Unable to parse notification content. Unexpected format: %@", alertObject);
        }
    }
    
    if (title == nil) {
        title = @"<unset>";
    }
    
    if (body == nil) {
        body = @"<unset>";
    }
    
    self.titleLabel.text = title;
    self.bodyLabel.text = body;
}

- (id)initWithUserInfo:(NSDictionary *)userInfo {
    self = [super initWithNibName:@"NotificationDetail" bundle:nil];
    if (self) {
        _userInfo = userInfo;
    }
    return self;
}

- (void)viewDidLayoutSubviews {
    //
    // Workaround the fact that UILabel doesn't support top-left aligned text.
    // Instead resize the control to fit the specified text.
    //
    [self.titleLabel sizeToFit];
    [self.bodyLabel sizeToFit];
}

- (IBAction)handleDismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
