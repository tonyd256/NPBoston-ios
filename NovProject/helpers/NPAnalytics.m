//
//  NPAnalytics.m
//  NovProject
//
//  Created by Tony DiPasquale on 8/21/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPAnalytics.h"
#import "Mixpanel.h"
#import "TestFlight.h"
#import "NPUser.h"

@implementation NPAnalytics

+ (void)setup
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"private" ofType:@"plist"];
    NSDictionary *private = [NSDictionary dictionaryWithContentsOfFile:path];

    [TestFlight takeOff:[private valueForKey:@"TestFlightKey"]];
    
    [Mixpanel sharedInstanceWithToken:[private valueForKey:@"MixpanelKey"]];
    [[Mixpanel sharedInstance] registerSuperProperties:@{@"os": [[UIDevice currentDevice] systemName],
                                                         @"os version": [[UIDevice currentDevice] systemVersion],
                                                         @"model": [[UIDevice currentDevice] model],
                                                         @"app version": [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]
     }];
}

+ (void)setUser:(NPUser *)user
{
    [[Mixpanel sharedInstance] identify:user.objectId];
    [[[Mixpanel sharedInstance] people] set:@"$name" to:user.name];
}

+ (void)track:(NSString *)event
{
    [[Mixpanel sharedInstance] track:event];
}

+ (void)track:(NSString *)event properties:(NSDictionary *)properties
{
    [[Mixpanel sharedInstance] track:event properties:properties];
}

- (void)track:(NSString *)event
{
    [self trackEvent:event];
}

- (void)track:(NSString *)event properties:(NSDictionary *)properties
{
    [self trackEvent:event withProperties:properties];
}

@end
