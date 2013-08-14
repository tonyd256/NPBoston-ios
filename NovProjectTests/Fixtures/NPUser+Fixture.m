//
//  NPUser+Fixture.m
//  NovProject
//
//  Created by Tony DiPasquale on 8/14/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPUser+Fixture.h"

@implementation NPUser (Fixture)

+ (NSDictionary *)jsonFixture
{
    return @{@"_id": @"123abc",
             @"email": @"test@gmail.com",
             @"fid": @"123456",
             @"name": @"John Test",
             @"gender": @"male",
             @"location": @"BOS",
             @"admin": @YES,
             @"token": @"123456789token"};
}

@end
