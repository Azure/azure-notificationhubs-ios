// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>

#import "MSNotificationHubMessage.h"

@implementation MSNotificationHubMessage

- (instancetype)initWithTitle:(NSString *)title withMessage:(NSString *)message withCustomData:(NSDictionary<NSString *, NSString *> *)customData {
  if ((self = [super init]) != nil) {
    _title = title;
    _message = message;
    _customData = customData;
  }
  return self;
}

@end
