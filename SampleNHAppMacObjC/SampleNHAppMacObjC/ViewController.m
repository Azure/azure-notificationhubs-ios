//
//  ViewController.m
//  SampleNHAppMacObjC
//
//  Created by Matthew Podwysocki on 6/30/20.
//  Copyright © 2020 Matthew Podwysocki. All rights reserved.
//

#import "ViewController.h"
#import <WindowsAzureMessaging/WindowsAzureMessaging.h>

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.TagsTable.delegate = self;
    self.TagsTable.dataSource = self;
    self.TagsTextField.delegate = self;
    
    _tags = [MSNotificationHub getTags];
    
    [_DeviceTokenTextField  setStringValue:[MSNotificationHub getPushChannel]];
    [_InstallationIdTextField setStringValue:[MSNotificationHub getInstallationId]];
    
    [self.TagsTable reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_tags count];
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    if (_tags[row]) {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"TagsCellID" owner:nil];
        
        cell.textField.stringValue = _tags[row];
        
        return cell;
    };
    
    return nil;
}

- (BOOL)control:(NSControl *)control textView:(NSTextField *)fieldEditor doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertNewline:)) {
        NSString *tag = self.TagsTextField.stringValue;
        if (tag != @"") {
            [MSNotificationHub addTag:tag];
            self.TagsTextField.stringValue = @"";
        }
        
        _tags = [MSNotificationHub getTags];
        [self.TagsTable reloadData];
        
        return YES;
    }
    
    return NO;
}

- (void) deleteSelectedItems: (NSTableView *)tableView {
    NSInteger row = [tableView selectedRow];
    
    if (row >= 0) {
        NSTableCellView *selectedRow = [tableView viewAtColumn:0 row:row makeIfNecessary:YES];
        [MSNotificationHub removeTag:selectedRow.textField.stringValue];
        
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
            [self deleteSelectedItems:self.TagsTable];
            return;
        }
    }
    [super keyDown:theEvent];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (void)application:(NSApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  NSLog(@"Did register for remote notifications with device token.");
}

- (void)application:(NSApplication *)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error {
  NSLog(@"Did fail to register for remote notifications with error %@.", [error localizedDescription]);
}

- (void)application:(NSApplication *)application didReceiveRemoteNotification:(NSDictionary<NSString *, id> *)userInfo {
  NSLog(@"Did receive remote notification");
}

- (void)notificationHub:(MSNotificationHub *)notificationHub didReceivePushNotification:(MSNotificationHubMessage *)message {
    NSLog(@"Message title: %@", message.title);
    NSLog(@"Message body: %@", message.body);
}

@end
