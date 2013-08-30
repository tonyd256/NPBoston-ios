//
//  NSDate+Fixture.m
//  NovProject
//
//  Created by Tony DiPasquale on 8/30/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NSDate+Fixture.h"

@implementation NSDate (Fixture)

+ (NSDate *)dateFixture
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:2013];
    [comps setMonth:7];
    [comps setDay:12];
    [comps setHour:14];
    [comps setMinute:55];
    [comps setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

+ (NSString *)dateStringFixture
{
    return @"2013-07-12T14:55:16Z";
}

@end
