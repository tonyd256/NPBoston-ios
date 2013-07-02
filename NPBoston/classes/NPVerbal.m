//
//  NPVerbal.m
//  NPBoston
//
//  Created by Tony DiPasquale on 6/17/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPVerbal.h"

@implementation NPVerbal

@synthesize objectId = _objectId;
@synthesize fid = _fid;
@synthesize uid = _uid;
@synthesize wid = _wid;
@synthesize name = _name;

+ (NPVerbal *)verbalWithObject:(id)object
{
    return [[self alloc] initWithObject:object];
}

- (NPVerbal *)initWithObject:(id)object
{
    if (self = [super init]) {
        self.objectId = [object valueForKey:@"_id"];
        id user = [object valueForKey:@"uid"];
        self.uid = [user valueForKey:@"_id"];
        self.wid = [object valueForKey:@"wid"];
        self.fid = [user valueForKey:@"fid"];
        self.name = [user valueForKey:@"name"];
        
        return self;
    } else {
        return nil;
    }
}


@end
