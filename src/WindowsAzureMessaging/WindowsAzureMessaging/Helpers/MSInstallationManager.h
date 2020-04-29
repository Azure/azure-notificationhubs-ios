//
//  MSInstallationManager.h
//  WindowsAzureMessaging
//
//  Created by User on 28.04.2020.
//  Copyright © 2020 Microsoft. All rights reserved.
//
#import <Foundation/Foundation.h>
@class MSInstallation;

@interface MSInstallationManager : NSObject
+ (MSInstallation *) initInstallationWith: (NSString *) connectionString;
+ (MSInstallation *) updateInstallationWith: (MSInstallation *) installation;
@end
