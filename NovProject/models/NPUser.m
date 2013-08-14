//
//  NPUser.m
//  NPBoston
//
//  Created by Tony DiPasquale on 6/12/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPUser.h"

@implementation NPUser

+ (NPUser *)userWithObject:(id)object
{
    return [[self alloc] initWithObject:object];
}

- (id)initWithObject:(id)object
{
    self = [super init];
    if (!self) return nil;
    
    _objectId = [object valueForKey:@"_id"];
    _name = [object valueForKey:@"name"];
    _email = [object valueForKey:@"email"];
    _gender = [object valueForKey:@"gender"];
    _location = [object valueForKey:@"location"];
    _fid = [object valueForKey:@"fid"];        
    _admin = [[object valueForKey:@"admin"] boolValue];
    
    return self;
}

@end
