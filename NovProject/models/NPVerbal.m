//
//  NPVerbal.m
//  NPBoston
//
//  Created by Tony DiPasquale on 6/17/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPVerbal.h"

@implementation NPVerbal

+ (NPVerbal *)verbalWithObject:(id)object
{
    return [[self alloc] initWithObject:object];
}

- (id)initWithObject:(id)object
{
    self = [super init];
    if (!self) return nil;
    
    _objectId = [object valueForKey:@"_id"];
    _wid = [object valueForKey:@"wid"];

    id user = [object valueForKey:@"uid"];
    
    if ([user isKindOfClass:[NSString class]]) {
        _uid = user;
        _fid = nil;
        _name = @"";
    } else {
        _uid = [user valueForKey:@"_id"];
        _fid = [user valueForKey:@"fid"];
        _name = [user valueForKey:@"name"];
    }
    
    return self;
}


@end
