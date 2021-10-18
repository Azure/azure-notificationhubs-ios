//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "ANHService+Private.h"
#import "ANHConstants.h"
#import "ANHDelegateForwarder.h"
#import "ANHLocalStorage.h"
#import "ANHInstallation.h"
#import "ANHLogger+Private.h"
#import "ANH_Errors.h"

@implementation ANHService

#pragma mark - Installation methods

+ (instancetype)sharedInstance {
    return nil;
}

@synthesize pushChannel = _pushChannel;

- (NSString *)installationId {
    return self.installation.installationId;
}

- (NSString *)pushChannel {
    if (![_installation.pushChannel isEqual:_pushChannel]) {
        _pushChannel = _installation.pushChannel;
    }
    
    return _pushChannel;
}

- (void)setPushChannel:(NSString *)pushChannel {
    if (![_installation.pushChannel isEqual:pushChannel]) {
        _pushChannel = pushChannel;
        _installation.pushChannel = pushChannel;
    }
}

- (ANHInstallation *)installation {
    _installation = [ANHLocalStorage objectForKey:self.currentInstallationKey];

    if (!_installation) {
        _installation = [ANHInstallation new];
        [ANHLocalStorage setObject:_installation forKey:self.currentInstallationKey];
    }

    return _installation;
}

- (void)upsertInstallation:(ANHInstallation *)installation {
    [ANHLocalStorage setObject:installation forKey:self.currentInstallationKey];
    
    if (!installation.pushChannel) {
        return;
    }
    
    ANHInstallation *lastInstallation = [ANHLocalStorage objectForKey:self.lastInstallationKey];
    
    if ([installation isEqual:lastInstallation]) {
        return;
    }
    
    [_debounceClient runPipeline:^{
        id<ANHInstallationEnrichmentDelegate> enrichmentDelegate = self.enrichmentDelegate;
        if ([enrichmentDelegate respondsToSelector:@selector(notificationHub:willEnrichInstallation:)]) {
            [enrichmentDelegate notificationHub:self willEnrichInstallation:installation];
            [ANHLocalStorage setObject:installation forKey:self.currentInstallationKey];
        }
    } managementHandler:^void(InstallationCompletionHandler completion) {
        id<ANHInstallationManagementDelegate> managementDelegate = self.managementDelegate;
        if ([managementDelegate respondsToSelector:@selector(notificationHub:willUpsertInstallation:completionHandler:)]) {
            [managementDelegate notificationHub:self willUpsertInstallation:installation completionHandler:completion];
        } else {
            [self.installationClient upsertInstallation:installation completion:completion];
        }
    } completionHandler:^(NSError *_Nullable error) {
        id<ANHInstallationLifecycleDelegate> lifecycleDelegate = self.lifecycleDelegate;
        if (error) {
            ANHLogError(kANHLogDomain, @"Error in saving installation: %@\n%@", [error localizedDescription], [error userInfo]);
            if ([lifecycleDelegate respondsToSelector:@selector(notificationHub:didFailToSaveInstallation:withError:)]) {
                [lifecycleDelegate notificationHub:self didFailToSaveInstallation:installation withError:error];
            }
            
        } else {
            [ANHLocalStorage setObject:installation forKey:self.lastInstallationKey];
            if ([lifecycleDelegate respondsToSelector:@selector(notificationHub:didSaveInstallation:)]) {
                [lifecycleDelegate notificationHub:self didSaveInstallation:installation];
            }
        }
    }];
}

#pragma mark - Tags Management

- (BOOL)addTag:(NSString *)tag {
    return [self addTags:[NSArray arrayWithObject:tag]];
}

- (BOOL)addTags:(NSArray<NSString *> *)tags {
    ANHInstallation *installation = [self installation];

    if ([installation addTags:tags]) {
        [self upsertInstallation:installation];
        return YES;
    }

    return NO;
}

- (void)clearTags {
    ANHInstallation *installation = [self installation];

    if (installation && installation.tags && [installation.tags count] > 0) {
        [installation clearTags];
        [self upsertInstallation:installation];
    }
}

- (NSArray<NSString *> *)tags {
    return [[self installation].tags allObjects];
}

- (BOOL)removeTag:(NSString *)tag {
    return [self removeTags:[NSArray arrayWithObject:tag]];
}

- (BOOL)removeTags:(NSArray<NSString *> *)tags {
    ANHInstallation *installation = [self installation];

    if (installation.tags == nil || [installation.tags count] == 0) {
        return NO;
    }

    [installation removeTags:tags];
    
    [self upsertInstallation:installation];

    return YES;
}

#pragma mark - Template Management

- (BOOL)setTemplate:(ANHInstallationTemplate *)template forKey:(NSString *)key {
    ANHInstallation *installation = [self installation];

    if ([installation setTemplate:template forKey:key]) {
        [self upsertInstallation:installation];
        return YES;
    }

    return NO;
}

- (BOOL)removeTemplateForKey:(NSString *)key {
    ANHInstallation *installation = [self installation];

    if (installation.templates == nil || [installation.templates count] == 0) {
        return NO;
    }

    if ([installation removeTemplateForKey:key]) {
        [self upsertInstallation:installation];
        return YES;
    }

    return NO;
}

- (ANHInstallationTemplate *)templateForKey:(NSString *)key {
    return [self.installation templateForKey:key];
}

- (NSDictionary<NSString *, ANHInstallationTemplate *> *)templates {
    return [[self installation].templates copy];
}

#pragma mark - Helpers

- (NSString *)convertTokenToString:(NSData *)token {
    if (!token) {
        return nil;
    }
    const unsigned char *dataBuffer = token.bytes;
    NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:(token.length * 2)];
    for (NSUInteger i = 0; i < token.length; ++i) {
        [stringBuffer appendFormat:@"%02x", dataBuffer[i]];
    }
    return [NSString stringWithString:stringBuffer];
}

#pragma mark - Support

+ (ANHLogLevel)logLevel {
    return ANHLogger.currentLogLevel;
}

+ (void)setLogLevel:(ANHLogLevel)logLevel {
    ANHLogger.currentLogLevel = logLevel;
    
    // The logger is not set at the time of swizzling but now may be a good time to flush the traces.
    [ANHDelegateForwarder flushTraceBuffer];
}

+ (ANHLogHandler)logHandler {
    return ANHLogger.logHandler;
}

+ (void)setLogHandler:(ANHLogHandler)logHandler {
    ANHLogger.logHandler = logHandler;
}

@end
