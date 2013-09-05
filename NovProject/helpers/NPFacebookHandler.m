//
//  NPFacebookHandler.m
//  NovProject
//
//  Created by Tony DiPasquale on 8/30/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "NPFacebookHandler.h"
#import "NPAppSession.h"
#import "NPAuthenticator.h"

@implementation NPFacebookHandler

#pragma mark - Facebook SDK

+ (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (error) {
                [self handleError:error];
            } else {
                [NPAnalytics track:@"login succeeded facbook"];
                [NPAuthenticator authenticateUserWithFacebookAccessToken:[FBSession activeSession].accessTokenData.accessToken];
            }
            break;

        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;

        default:
            break;
    }

    if (error)
        [self handleError:error];
}

+ (void)handleError:(NSError *)error
{
    NSString *alertMessage, *alertTitle;
    if (error.fberrorShouldNotifyUser) {
        alertTitle = @"Something Went Wrong";
        alertMessage = error.fberrorUserMessage;
    } else if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
        NSLog(@"User cancelled FB login");
        [NPAnalytics track:@"login cancelled facebook"];
    } else if (error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
    } else {
        alertTitle = @"Unknown Facebook Error";
        alertMessage = @"Try again later";
        NSLog(@"FB error: %@", error);
    }

    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [NPAnalytics track:@"login error facebook" properties:@{@"error": error.localizedDescription}];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:NPSessionAuthenticationFailedNotification object:nil];
}

+ (BOOL)openFacebookSessionWithAllowLoginUI:(BOOL)allowLoginUI
{
    return [FBSession openActiveSessionWithReadPermissions:@[@"email", @"user_location"] allowLoginUI:allowLoginUI completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
        [self sessionStateChanged:session state:state error:error];
    }];
}

@end
