//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#ifndef ANH_INSTALLTION_CLIENT_h
#define ANH_INSTALLTION_CLIENT_h

#import <Foundation/Foundation.h>
#import "ANHConnection.h"
#import "ANHInstallation.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *const kANHUserAgentFormat = @"NOTIFICATIONHUBS/%@(api-origin=IosSdkV%@; os=%@; os_version=%@;)";
static NSString *const kANHAPIVersion = @"2020-06";

typedef void (^ANHCompletionHandler)(NSError *_Nullable);
typedef void (^ANHInstallationCompletionHandler)(ANHInstallation *_Nullable, NSError *_Nullable);

NS_SWIFT_NAME(InstallationClient)
@interface ANHInstallationClient : NSObject

- (id)initWithConnectionString:(ANHConnection *)connectionString hubName:(NSString *)hubName;

- (void)getInstallation:(NSString *)installationId completion:(ANHInstallationCompletionHandler)completion;

- (void)upsertInstallation:(ANHInstallation *)installation completion:(ANHCompletionHandler)completion;;

- (void)patchInstallation:(NSString *)installationId patches:(NSArray *)patches completion:(ANHCompletionHandler)completion;;

- (void)deleteInstallation:(NSString *)installationId completion:(ANHCompletionHandler)completion;;

@end

NS_ASSUME_NONNULL_END

#endif
