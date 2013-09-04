//
//  NPCacheManager.m
//  NovProject
//
//  Created by Tony DiPasquale on 8/19/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPCacheManager.h"
#import "NPAPIClient.h"

NSString * const kWorkoutTypesCache = @"workoutTypesCache";

@implementation NPCacheManager

+ (NPCacheManager *)sharedManager
{
    static NPCacheManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NPCacheManager alloc] init];
    });
    return manager;
}

- (void)refreshWorkoutTypes
{
    [[NPAPIClient sharedClient] fetchWorkoutTypesWithSuccessBlock:^(NSArray *workoutTypes) {
        [[NSUserDefaults standardUserDefaults] setObject:workoutTypes forKey:kWorkoutTypesCache];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

- (NSArray *)workoutTypes
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kWorkoutTypesCache];
}

@end
