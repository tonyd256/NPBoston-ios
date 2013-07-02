//
//  NPUser.m
//  NPBoston
//
//  Created by Tony DiPasquale on 6/12/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPUser.h"

@implementation NPUser

@synthesize objectId = _objectId;
@synthesize name = _name;
@synthesize email = _email;
@synthesize fid = _fid;
@synthesize admin = _admin;

+ (NPUser *)userWithObject:(id)object
{
    return [[self alloc] initWithObject:object];
}

- (NPUser *)initWithObject:(id)object
{
    if (self = [super init]) {
        self.objectId = [object valueForKey:@"_id"];
        self.name = [object valueForKey:@"name"];
        self.email = [object valueForKey:@"email"];
        self.fid = [object valueForKey:@"fid"];        
        self.admin = [object containsObject:@"admin"];
        
        return self;
    } else {
        return nil;
    }
}

@end
