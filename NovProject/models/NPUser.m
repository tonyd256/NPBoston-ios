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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) return nil;
    
    _objectId = [aDecoder decodeObjectForKey:@"objectId"];
    _name = [aDecoder decodeObjectForKey:@"name"];
    _email = [aDecoder decodeObjectForKey:@"email"];
    _gender = [aDecoder decodeObjectForKey:@"gender"];
    _location = [aDecoder decodeObjectForKey:@"location"];
    _fid = [aDecoder decodeObjectForKey:@"fid"];
    _admin = [aDecoder decodeBoolForKey:@"admin"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_objectId forKey:@"objectId"];
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_email forKey:@"email"];
    [encoder encodeObject:_fid forKey:@"fid"];
    [encoder encodeBool:_admin forKey:@"admin"];
    [encoder encodeObject:_gender forKey:@"gender"];
    [encoder encodeObject:_location forKey:@"location"];
}

@end
