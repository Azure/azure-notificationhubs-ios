//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "SetupViewController.h"
#import "NotificationsTableViewController.h"

static NSString *const kNHMessageReceived = @"MessageReceived";
static void * const SetupViewControllerKVOContext = (void*)&SetupViewControllerKVOContext;

@interface SetupViewController ()

@end

@implementation SetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[ANHNotificationHub sharedInstance] addObserver:self forKeyPath:@"pushChannel" options:NSKeyValueObservingOptionNew context:SetupViewControllerKVOContext];
    
    // Do any additional setup after loading the view.
    self.tags = [ANHNotificationHub sharedInstance].tags;
    
    self.addNewTagTextField.delegate = self;
    self.tagsTable.delegate = self;
    self.tagsTable.dataSource = self;
    [self.tagsTable reloadData];
    self.userId.delegate = self;
    
    self.deviceTokenLabel.text = [ANHNotificationHub sharedInstance].pushChannel;
    self.installationIdLabel.text = [ANHNotificationHub sharedInstance].installationId;
    self.userId.text = [ANHNotificationHub sharedInstance].userId;
    
    self.notificationsTableView = (NotificationsTableViewController*) [[(UINavigationController*)[[self.tabBarController viewControllers] objectAtIndex:1] viewControllers] objectAtIndex:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePushNotification:) name:kNHMessageReceived object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNHMessageReceived object:nil];
    
    [[ANHNotificationHub sharedInstance] removeObserver:self forKeyPath:@"pushChannel" context:SetupViewControllerKVOContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                  ofObject:(id)object
                    change:(NSDictionary *)change
                   context:(void *)context {
    if (context != SetupViewControllerKVOContext) {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context]; return;
        
    }
    
    if ([keyPath isEqual: @"pushChannel"]) {
        self.deviceTokenLabel.text = [ANHNotificationHub sharedInstance].pushChannel;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Hide the keyboard.
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if(textField.tag == 0) {
        [ANHNotificationHub sharedInstance].userId = textField.text;
    } else if (![textField.text isEqual: @""]) {
        [[ANHNotificationHub sharedInstance] addTag:textField.text];
        self.tags = [ANHNotificationHub sharedInstance].tags;
        textField.text = @"";
        [self.tagsTable reloadData];
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"TagCell";
    
    TagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.tagLabel.text = self.tags[indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tags count];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[ANHNotificationHub sharedInstance] removeTag:self.tags[indexPath.row]];
        self.tags = [ANHNotificationHub sharedInstance].tags;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.tagsTable reloadData];
    }
}

- (void)didReceivePushNotification:(NSNotification *)notification {
    ANHNotificationHubMessage *message = [notification.userInfo objectForKey:@"message"];
    
    [self.notificationsTableView addNotification:message];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message.title
                         message:message.body
                  preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alertController dismissViewControllerAnimated:YES completion: nil];
    });
}

@end
