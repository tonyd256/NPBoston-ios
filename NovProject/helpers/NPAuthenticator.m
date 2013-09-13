//
//  NPAuthenticator.m
//  NovProject
//
//  Created by Tony DiPasquale on 8/30/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPAuthenticator.h"
#import "NPAPIClient.h"
#import "NPAppSession.h"

@implementation NPAuthenticator

#pragma mark - Block implementations

void (^NPAuthenticationSuccessfulBlock)(NPUser *, NSString *) = ^(NPUser *user, NSString *token){
    [NPAppSession sharedSession].user = user;
    [NPAppSession sharedSession].token = token;
    [[NSNotificationCenter defaultCenter] postNotificationName:NPSessionAuthenticationSucceededNotification object:nil];
};

void (^NPAuthenticationFailureBlock)() = ^{
    [NPAppSession sharedSession].user = nil;
    [NPAppSession sharedSession].token = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:NPSessionAuthenticationFailedNotification object:nil];
};

#pragma mark - User authentication

+ (void)createUserWithName:(NSString *)name email:(NSString *)email password:(NSString *)password location:(NSString *)location gender:(NSString *)gender
{
    NSDictionary *parameters = @{@"email": email,
                                 @"pass": password,
                                 @"name": name,
                                 @"location": location,
                                 @"gender": gender};
    
    [[NPAPIClient sharedClient] createUserWithParameters:parameters withSuccessBlock:NPAuthenticationSuccessfulBlock failureBlock:NPAuthenticationFailureBlock];
}

+ (void)authenticateUserWithEmail:(NSString *)email andPassword:(NSString *)password
{
    [[NPAPIClient sharedClient] authenticateUserWithParameters:@{@"email": email, @"pass": password} withSuccessBlock:NPAuthenticationSuccessfulBlock failureBlock:NPAuthenticationFailureBlock];
}

+ (void)authenticateUserWithFacebookAccessToken:(NSString *)accessToken
{
    [[NPAPIClient sharedClient] fetchUserForFacebookAccessToken:accessToken withSuccessBlock:NPAuthenticationSuccessfulBlock failureBlock:NPAuthenticationFailureBlock];
}

@end
