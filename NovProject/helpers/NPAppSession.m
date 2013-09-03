//
//  NPAppSession.m
//  NovProject
//
//  Created by Tony DiPasquale on 8/27/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPAppSession.h"
#import "LUKeychainAccess.h"

NSString * const NPSessionAuthenticationSucceededNotification = @"NPSessionAuthenticationSucceededNotification";
NSString * const NPSessionAuthenticationFailedNotification = @"NPSessionAuthenticationFailedNotification";

@implementation NPAppSession

+ (NPAppSession *)sharedSession
{
    static NPAppSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        session = [[NPAppSession alloc] init];
    });
    return session;
}

#pragma mark - Property overrides

- (NPUser *)user
{
    return [[LUKeychainAccess standardKeychainAccess] objectForKey:@"user"];
}

- (void)setUser:(NPUser *)user
{
    [self willChangeValueForKey:@"user"];
    [[LUKeychainAccess standardKeychainAccess] setObject:user forKey:@"user"];
    [self didChangeValueForKey:@"user"];
}

- (NSString *)token
{
    return [[LUKeychainAccess standardKeychainAccess] objectForKey:@"token"];
}

- (void)setToken:(NSString *)token
{
    [self willChangeValueForKey:@"token"];
    [[LUKeychainAccess standardKeychainAccess] setObject:token forKey:@"token"];
    [self didChangeValueForKey:@"token"];
}

#pragma mark - Public methods

- (void)authenticate
{
    if (self.token && self.user)
        [[NSNotificationCenter defaultCenter] postNotificationName:NPSessionAuthenticationSucceededNotification object:nil];
    else
        [[NSNotificationCenter defaultCenter] postNotificationName:NPSessionAuthenticationFailedNotification object:nil];
}

@end
