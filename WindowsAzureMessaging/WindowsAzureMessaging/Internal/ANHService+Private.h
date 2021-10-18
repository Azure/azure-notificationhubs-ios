//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "ANHService.h"
#import "ANHConnection.h"
#import "ANHDebounceClient.h"
#import "ANHInstallationClient.h"
#import "ANHInstallationManagementDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ANHService ()

/**
 * Method converts NSData to NSString.
 *
 * @param token The push token.
 */
- (NSString *)convertTokenToString:(NSData *)token;

@property (nonatomic, copy) NSString *currentInstallationKey;
@property (nonatomic, copy) NSString *lastInstallationKey;

/**
 * The current installation for the client.
 */
@property (nonatomic, strong) ANHInstallation *installation;

/**
 * Upserts the given installation
 * @param installation The installation to save on the back end.
 */
- (void)upsertInstallation:(ANHInstallation *)installation;


@property (nonatomic, strong, nullable) ANHConnection *connectionString;

@property (nonatomic, strong, nullable) ANHInstallationClient *installationClient;

@property (nonatomic, strong, nullable) ANHDebounceClient *debounceClient;

@property(nonatomic, weak, nullable) id<ANHInstallationManagementDelegate> managementDelegate;

@property (nonatomic, nullable) NSString *pushChannel;

@end

NS_ASSUME_NONNULL_END
