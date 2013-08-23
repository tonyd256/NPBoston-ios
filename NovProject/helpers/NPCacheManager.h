//
//  NPCacheManager.h
//  NovProject
//
//  Created by Tony DiPasquale on 8/19/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

extern NSString * const kWorkoutTypesCache;

@interface NPCacheManager : NSObject

@property (strong, nonatomic) NSUserDefaults *userDefaults;

+ (NPCacheManager *)sharedManager;

- (void)refreshWorkoutTypes;
- (NSArray *)workoutTypes;

@end
