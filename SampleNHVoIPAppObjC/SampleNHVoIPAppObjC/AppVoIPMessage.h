//
//  AppVoIPMessage.h
//  SampleNHVoIPAppObjC
//
//  Created by Matthew Podwysocki on 10/17/21.
//

#ifndef AppVoIPMessage_h
#define AppVoIPMessage_h

#import <Foundation/Foundation.h>

@interface AppVoIPMessage : NSObject

- (instancetype)initWithUserInfo:(NSDictionary *)userInfo;

@property(nonatomic, readonly, copy) NSString *title;

/**
 * Notification message.
 */
@property(nonatomic, readonly, copy) NSString *body;

/**
 * The notification badge count.
 */
@property(nonatomic, readonly, copy) NSNumber *badge;

/**
 * The content-available from the APNS message.
 */
@property(nonatomic, readonly, copy) NSNumber *contentAvailable;

/**
 * Notification data.
 */
@property(nonatomic, readonly, strong) NSDictionary *userInfo;

@end

#endif /* AppVoIPMessage_h */
