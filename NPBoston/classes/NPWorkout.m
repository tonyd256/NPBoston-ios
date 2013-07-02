//
//  NPWorkout.m
//  NPBoston
//
//  Created by Tony DiPasquale on 5/1/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPWorkout.h"
#import "NPResult.h"

@implementation NPWorkout

@synthesize objectId = _objectId;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize details = _details;
@synthesize type = _type;
@synthesize time = _time;
@synthesize amount = _amount;
@synthesize date = _date;
@synthesize lat = _lat;
@synthesize lng = _lng;
@synthesize url = _url;
@synthesize verbal = _verbal;
@synthesize result = _result;

+ (NPWorkout *)workoutWithObject:(id)object
{
    return [[self alloc] initWithObject:object];
}

- (NPWorkout *)initWithObject:(id)object
{
    if (self = [super init]) {
        self.objectId = [object valueForKey:@"_id"];
        self.title = [object valueForKey:@"title"];
        self.subtitle = [object valueForKey:@"subtitle"];
        self.details = [object valueForKey:@"details"];
        self.type = [[object objectForKey:@"type"] valueForKey:@"type"];
        self.time = [object valueForKey:@"time"];
        self.amount = [object valueForKey:@"amount"];
        self.date = [object valueForKey:@"date"];
        
        if ([[object valueForKey:@"lat"] isEqual:[NSNull null]]) {
            self.lat = nil;
        } else {
            self.lat = [object valueForKey:@"lat"];
        }
        
        if ([[object valueForKey:@"lng"] isEqual:[NSNull null]]) {
            self.lng = nil;
        } else {
            self.lng = [object valueForKey:@"lng"];
        }
        
        if ([[object valueForKey:@"url"] isEqual:[NSNull null]] || [[object valueForKey:@"url"] isEqual:@""]) {
            self.url = nil;
        } else {
            self.url = [object valueForKey:@"url"];
        }
        
        NSArray *vs = [object valueForKey:@"verbals"];
        
        if (vs.count > 0) {
            self.verbal = [NPVerbal verbalWithObject:[vs objectAtIndex:0]];
        } else {
            self.verbal = nil;
        }
    
        NSArray *res = [object valueForKey:@"results"];
        if (res.count > 0) {
            self.result = [NPResult resultWithObject:[res objectAtIndex:0]];
        } else {
            self.result = nil;
        }
        
        return self;
    } else {
        return nil;
    }
}

@end
