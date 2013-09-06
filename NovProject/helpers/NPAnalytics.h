//
//  NPAnalytics.h
//  NovProject
//
//  Created by Tony DiPasquale on 8/21/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

@class NPUser;

@interface NPAnalytics : NSObject

+ (void)setup;
+ (void)setUser:(NPUser *)user;

+ (void)track:(NSString *)event;
+ (void)track:(NSString *)event properties:(NSDictionary *)properties;

+ (void)trackError:(NSString *)event message:(NSString *)message;

@end
