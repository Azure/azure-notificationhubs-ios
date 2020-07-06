//
//  ViewController.h
//  SampleNHAppMacObjC
//
//  Created by Matthew Podwysocki on 6/30/20.
//  Copyright © 2020 Matthew Podwysocki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController<NSTextFieldDelegate, NSTableViewDelegate, NSTableViewDataSource, NSApplicationDelegate>

@property (nonatomic, copy) NSArray<NSString *> *tags;

@property (weak) IBOutlet NSTextField *InstallationIdTextField;
@property (weak) IBOutlet NSTextField *DeviceTokenTextField;
@property (weak) IBOutlet NSTableView *TagsTable;
@property (weak) IBOutlet NSTextField *TagsTextField;

@end

