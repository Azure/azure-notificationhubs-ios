// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "SetupViewController.h"

@interface SetupViewController ()

@end

@implementation SetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tags = [MSNotificationHub getTags];
    
    self.addNewTagTextField.delegate = self;
    self.tagsTable.delegate = self;
    self.tagsTable.dataSource = self;
    [self.tagsTable reloadData];
    
    self.deviceTokenLabel.text = @"device-token";
    self.installationIdLabel.text = @"installation-id";
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Hide the keyboard.
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [MSNotificationHub addTag:textField.text];
    self.tags = [MSNotificationHub getTags];
    textField.text = @"";
    [self.tagsTable reloadData];
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
        [MSNotificationHub removeTag:self.tags[indexPath.row]];
        self.tags = [MSNotificationHub getTags];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.tagsTable reloadData];
    }
}


@end
