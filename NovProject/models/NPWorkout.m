//
//  NPWorkout.m
//  NovProject
//
//  Created by Tony DiPasquale on 5/1/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPWorkout.h"
#import "NPResult.h"
#import "NPVerbal.h"
#import "NPDateFormatter.h"

@implementation NPWorkout

+ (NPWorkout *)workoutWithObject:(id)object
{
    return [[self alloc] initWithObject:object];
}

- (id)initWithObject:(id)object
{
    self = [super init];
    if (!self) return nil;
    
    _objectId = [object valueForKey:@"_id"];
    _title = [object valueForKey:@"title"];
    _subtitle = [object valueForKey:@"subtitle"];
    _details = [object valueForKey:@"details"];
    _type = [[object objectForKey:@"type"] valueForKey:@"type"];
    _time = [object valueForKey:@"time"];
    _amount = [object valueForKey:@"amount"];
    
    _date = [[NPDateFormatter sharedFormatter].serverFormatter dateFromString:(NSString *)[[object valueForKey:@"date"] substringToIndex:16]];
    
    _location = [object valueForKey:@"location"];
    _verbalsCount = [object valueForKey:@"verbalsCount"];
    _resultsCount = [object valueForKey:@"resultsCount"];
    
    if ([[object valueForKey:@"lat"] isEqual:[NSNull null]]) {
        _lat = nil;
    } else {
        _lat = [object valueForKey:@"lat"];
    }
    
    if ([[object valueForKey:@"lng"] isEqual:[NSNull null]]) {
        _lng = nil;
    } else {
        _lng = [object valueForKey:@"lng"];
    }
    
    if ([[object valueForKey:@"url"] isEqual:[NSNull null]] || [[object valueForKey:@"url"] isEqual:@""]) {
        _url = nil;
    } else {
        _url = [object valueForKey:@"url"];
    }
    
    NSArray *vs = [object valueForKey:@"verbals"];
    
    if (vs.count > 0) {
        _verbal = [NPVerbal verbalWithObject:[vs objectAtIndex:0]];
    } else {
        _verbal = nil;
    }

    NSArray *res = [object valueForKey:@"results"];
    if (res.count > 0) {
        _result = [NPResult resultWithObject:[res objectAtIndex:0]];
    } else {
        _result = nil;
    }
    
    return self;
}

- (NSString *)displayDate
{
    return [[NPDateFormatter sharedFormatter].displayFormatter stringFromDate:self.date];
}

@end
