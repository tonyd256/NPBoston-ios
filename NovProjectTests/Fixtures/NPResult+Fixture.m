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

+ (NSDictionary *)jsonFixture
{
    return @{@"_id": @"234bcd",
             @"amount": @34,
             @"comment": @"Test Comment",
             @"pr": @"No",
             @"time": @3500,
             @"type": [NPWorkout workoutTypeJSONFixture],
             @"uid": [NPUser jsonFixture],
             @"wid": @"123abc"};
}

@end
