//
//  NPAppDelegate.m
//  NPBoston
//
//  Created by Tony DiPasquale on 4/17/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AFNetworking.h"
#import "WCAlertView.h"
#import "NPCacheManager.h"
#import "NPAnalytics.h"

@implementation NPAppDelegate

NSString *const FBSessionStateChangedNotification = @"com.tstormlabs.novproject:FBSessionStateChangedNotification";

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIStoryboard *sb = [[self.window rootViewController] storyboard];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"unlocked"]) {
        [self.window setRootViewController:[sb instantiateViewControllerWithIdentifier:@"SimpleAppFlow"]];
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.    
    [[NPAnalytics sharedAnalytics] setup];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    [WCAlertView setDefaultStyle:WCAlertViewStyleDefault];
    
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:(32.0/255.0) green:(163.0/255.0) blue:(190.0/255.0) alpha:1.0]];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSession.activeSession handleDidBecomeActive];
    [[NPCacheManager sharedManager] refreshWorkoutTypes];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [FBSession.activeSession close];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}

#pragma mark Facebook SDK

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                NSLog(@"User Session Found");
            } else {
                NSString *alertMessage, *alertTitle;
                if (error.fberrorShouldNotifyUser) {
                    alertTitle = @"Something Went Wrong";
                    alertMessage = error.fberrorUserMessage;
                } else if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
                    NSLog(@"User cancelled FB login");
                    [[Mixpanel sharedInstance] track:@"login cancelled facebook"];
                } else if (error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession) {
                    alertTitle = @"Session Error";
                    alertMessage = @"Your current session is no longer valid. Please log in again.";
                } else {
                    alertTitle = @"Unknown Facebook Error";
                    alertMessage = @"Try again later";
                    [[Mixpanel sharedInstance] track:@"login error facebook" properties:@{@"error": error.localizedDescription}];
                    NSLog(@"FB error: %@", error);
                }
                
                if (alertMessage) {
                    [[[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
            }
            break;
            
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
            
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FBSessionStateChangedNotification object:session];
    
    if (error) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
    }
}

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI
{
    return [FBSession openActiveSessionWithReadPermissions:@[@"email", @"user_location"] allowLoginUI:allowLoginUI completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
        [self sessionStateChanged:session state:state error:error];
    }];
}

@end
