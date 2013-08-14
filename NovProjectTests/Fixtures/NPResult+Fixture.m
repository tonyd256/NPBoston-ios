//
//  NPResult+Fixture.m
//  NovProject
//
//  Created by Tony DiPasquale on 8/14/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPResult+Fixture.h"
#import "NPWorkout+Fixture.h"
#import "NPUser+Fixture.h"

@implementation NPResult (Fixture)

+ (NSDictionary *)simpleJSONFixture
{
    return @{@"_id": @"234bcd",
             @"amount": @34,
             @"comment": @"Test Comment",
             @"pr": @"No",
             @"time": @3500,
             @"type": @"520196a5d20f9a0000000003",
             @"uid": @"1a2b3c",
             @"wid": @"123abc"};
}

+ (NSDictionary *)fullJSONFixture
{
    return @{@"_id": @"234bcd",
             @"amount": @34,
             @"comment": @"Test Comment",
             @"pr": @"No",
             @"time": @3500,
             @"type": [NPWorkout typeJSONFixture],
             @"uid": [NPUser jsonFixture],
             @"wid": @"123abc"};
}

@end
