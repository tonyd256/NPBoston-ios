//
//  NPWorkout+Fixture.m
//  NovProject
//
//  Created by Tony DiPasquale on 8/14/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPWorkout+Fixture.h"
#import "NPResult+Fixture.h"
#import "NPVerbal+Fixture.h"

@implementation NPWorkout (Fixture)

+ (NSDictionary *)jsonFixture
{
    return @{@"_id": @"123abc",
             @"title": @"Test Title",
             @"subtitle": @"Test Subtitle",
             @"details": @"Test Details",
             @"location": @"BOS",
             @"date": @"2013-08-15T10:30:00.000Z",
             @"lat": @42.366297,
             @"lng": @-71.127089,
             @"time": @0,
             @"amount": @0,
             @"resultCount": @1,
             @"verbalCount": @1,
             @"type": [NPWorkout typeJSONFixture],
             @"results": @[[NPResult simpleJSONFixture]],
             @"verbals": @[[NPVerbal simpleJSONFixture]]};
}

+ (NSDictionary *)typeJSONFixture
{
    return @{@"_id": @"0987hdfd",
             @"type": @"Test Type"};
}

@end
