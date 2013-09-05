//
//  NPAppDelegate.m
//  NovProject
//
//  Created by Tony DiPasquale on 4/17/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "NPAppDelegate.h"
#import "AFNetworking.h"
#import "WCAlertView.h"
#import "NPCacheManager.h"
#import "NPAnalytics.h"
#import "NPColors.h"

@implementation NPAppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NPAnalytics sharedAnalytics] setup];

    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

    [WCAlertView setDefaultStyle:WCAlertViewStyleDefault];

    [[UINavigationBar appearance] setTintColor:[NPColors NPBlue]];

    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSession.activeSession handleDidBecomeActive];
    [[NPCacheManager sharedManager] refreshWorkoutTypes];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [FBSession.activeSession close];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}

@end
