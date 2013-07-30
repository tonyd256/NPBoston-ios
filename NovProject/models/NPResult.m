//
//  NPResult.m
//  NPBoston
//
//  Created by Tony DiPasquale on 5/1/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPResult.h"
#import "NPUtils.h"

@implementation NPResult

+ (NPResult *)resultWithObject:(id)object
{
    return [[self alloc] initWithObject:object];
}

- (id)initWithObject:(id)object
{
    self = [super init];
    if (!self) return nil;
    
    _objectId = [object valueForKey:@"_id"];
    _uid = [object valueForKey:@"uid"];
    _userName = [object valueForKey:@"userName"];
    _wid = [object valueForKey:@"wid"];
    _type = [object valueForKey:@"type"];
    
    if ([[object valueForKey:@"time"] isKindOfClass:[NSString class]]) {
        _time = [NPUtils stringToTime:[object valueForKey:@"time"]];
    } else {
        _time = [object valueForKey:@"time"];
    }
    
    _amount = [object valueForKey:@"amount"];
    _pr = [object valueForKey:@"pr"];
    _comment = [object valueForKey:@"comment"];
    
    return self;
}

@end
