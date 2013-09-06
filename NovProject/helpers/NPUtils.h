//
//  NPUtils.h
//  NovProject
//
//  Created by Tony DiPasquale on 7/23/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

@interface NPUtils : NSObject

+ (NSString *)timeToString:(NSNumber *)timeObj;
+ (NSNumber *)stringToTime:(NSString *)timeStr;

@end
