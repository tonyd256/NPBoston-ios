//
//  NPVerbal+Fixture.m
//  NovProject
//
//  Created by Tony DiPasquale on 8/14/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPVerbal+Fixture.h"
#import "NPUser+Fixture.h"

@implementation NPVerbal (Fixture)

+ (NSDictionary *)simpleJSONFixture
{
    return @{@"_id": @"345cde",
             @"uid": @"1a2b3c",
             @"wid": @"123abc"};
}

+ (NSDictionary *)fullJSONFixture
{
    return @{@"_id": @"345cde",
             @"uid": [NPUser jsonFixture],
             @"wid": @"123abc"};
}

@end
