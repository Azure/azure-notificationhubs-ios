//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "ViewController.h"
#import <WindowsAzureMessaging/WindowsAzureMessaging.h>
#import "NotificationDetails.h"

static NSString *const kNHMessageReceived = @"MessageReceived";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tagsTable.delegate = self;
    self.tagsTable.dataSource = self;
    self.tagsTextField.delegate = self;
    self.userIdTextField.delegate = self;
    
    self.notificationsTableViewController = [[NotificationsTableViewController alloc] initWithTableView: self.notificationsTable];

    self.userIdTextField.placeholderString = [MSNotificationHub getUserId];
    _tags = [MSNotificationHub getTags];
    
    [_deviceTokenTextField  setStringValue:[MSNotificationHub getPushChannel]];
    [_installationIdTextField setStringValue:[MSNotificationHub getInstallationId]];
    
    [self.tagsTable reloadData];
    [self.notificationsTable reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePushNotification:) name:kNHMessageReceived object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNHMessageReceived object:nil];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_tags count];
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    if (_tags[row]) {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"TagsCellID" owner:nil];
        
        cell.textField.stringValue = _tags[row];
        
        return cell;
    }
    
    return nil;
}

- (BOOL)control:(NSControl *)control textView:(NSTextField *)fieldEditor doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertNewline:)) {
        if (control == self.tagsTextField) {
            [self updateTag];
        }

        if (control == self.userIdTextField) {
            [self updateUserId];
        }
        
        return YES;
    }
    
    return NO;
}

- (void) updateTag {
    NSString *tag = self.tagsTextField.stringValue;
    if (![tag isEqual:@""]) {
        [MSNotificationHub addTag:tag];
        self.tagsTextField.stringValue = @"";
    }
    
    _tags = [MSNotificationHub getTags];
    [self.tagsTable reloadData];
}

- (void) updateUserId {
    if (![self.userIdTextField.stringValue isEqual:@""]) {
        [MSNotificationHub setUserId:self.userIdTextField.stringValue];
        self.userIdTextField.stringValue = @"";
        self.userIdTextField.placeholderString = [MSNotificationHub getUserId];
    }
}

- (void) deleteSelectedItems: (NSTableView *)tableView {
    NSInteger row = [tableView selectedRow];
    if (row >= 0) {
        NSTableCellView *selectedRow = [tableView viewAtColumn:0 row:row makeIfNecessary:YES];
        NSString *tag = selectedRow.textField.stringValue;
        [MSNotificationHub removeTag:tag];
        
        _tags = [MSNotificationHub getTags];
        
        [tableView deselectAll:nil];
        [tableView reloadData];
    }
}

- (void)keyDown:(NSEvent *)theEvent {
    if ([theEvent modifierFlags]) {
        NSString *theKey = [theEvent charactersIgnoringModifiers];
        unichar keyChar = [theKey characterAtIndex:0];
        if ( keyChar == NSDeleteFunctionKey ) {
            [self deleteSelectedItems:self.tagsTable];
            return;
        }
    }
    [super keyDown:theEvent];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (void)didReceivePushNotification:(NSNotification *)notification {
    MSNotificationHubMessage *message = [notification.userInfo objectForKey:@"message"];
    
    NSLog(@"Message title: %@", message.title);
    NSLog(@"Message body: %@", message.body);
    
    [self.notificationsTableViewController addNotificationHubMessage:message];
    [self.notificationsTable reloadData];
}

@end
