//
//  NPAppSession.h
//  NovProject
//
//  Created by Tony DiPasquale on 8/27/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

@class NPUser;

extern NSString * const NPSessionAuthenticationSucceededNotification;
extern NSString * const NPSessionAuthenticationFailedNotification;

@interface NPAppSession : NSObject

@property (strong, nonatomic) NPUser *user;
@property (strong, nonatomic) NSString *token;

+ (NPAppSession *)sharedSession;
- (void)authenticate;

@end
