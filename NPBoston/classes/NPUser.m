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
@synthesize gender = _gender;
@synthesize location = _location;

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
        self.gender = [object valueForKey:@"gender"];
        self.location = [object valueForKey:@"location"];
        self.fid = [object valueForKey:@"fid"];        
        self.admin = [[object valueForKey:@"admin"] boolValue];
        
        return self;
    } else {
        return nil;
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self != nil) {
        self.objectId = [aDecoder decodeObjectForKey:@"objectId"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.email = [aDecoder decodeObjectForKey:@"email"];
        self.gender = [aDecoder decodeObjectForKey:@"gender"];
        self.location = [aDecoder decodeObjectForKey:@"location"];
        self.fid = [aDecoder decodeObjectForKey:@"fid"];
        self.admin = [aDecoder decodeBoolForKey:@"admin"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.objectId forKey:@"objectId"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.email forKey:@"email"];
    [encoder encodeObject:self.fid forKey:@"fid"];
    [encoder encodeBool:self.admin forKey:@"admin"];
    [encoder encodeObject:self.gender forKey:@"gender"];
    [encoder encodeObject:self.location forKey:@"location"];
}

@end
