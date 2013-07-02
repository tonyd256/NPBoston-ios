//
//  NPResult.m
//  NPBoston
//
//  Created by Tony DiPasquale on 5/1/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPResult.h"

@implementation NPResult

@synthesize objectId = _objectId;
@synthesize uid = _uid;
@synthesize userName = _userName;
@synthesize wid = _wid;
@synthesize type = _type;
@synthesize time = _time;
@synthesize amount = _amount;
@synthesize pr = _pr;
@synthesize comment = _comment;

+ (NPResult *)resultWithObject:(id)object
{
    return [[self alloc] initWithObject:object];
}

- (NPResult *)initWithObject:(id)object
{
    if (self = [super init]) {
        self.objectId = [object valueForKey:@"_id"];
        self.uid = [object valueForKey:@"uid"];
        self.userName = [object valueForKey:@"userName"];
        self.wid = [object valueForKey:@"wid"];
        self.type = [object valueForKey:@"type"];
        
        if ([[object valueForKey:@"time"] isKindOfClass:[NSString class]]) {
            self.time = [NPResult stringToTime:[object valueForKey:@"time"]];
        } else {
            self.time = [object valueForKey:@"time"];
        }
        
        self.amount = [object valueForKey:@"amount"];
        self.pr = [object valueForKey:@"pr"];
        self.comment = [object valueForKey:@"comment"];
        
        return self;
    } else {
        return nil;
    }
}

+ (NSNumber *)stringToTime:(NSString *)timeStr
{
    NSArray * timeArr = [timeStr componentsSeparatedByString:@":"];
    int time = ([[timeArr objectAtIndex:0] integerValue] * 3600) + ([[timeArr objectAtIndex:1] integerValue] * 60) + [[timeArr objectAtIndex:2] integerValue];
    
    return [NSNumber numberWithInt:time];
}

+ (NSString *)timeToString:(NSNumber *)timeObj
{
    int time = [timeObj integerValue];
    int hours = time / 3600;
    time -= hours * 3600;
    int min = time / 60;
    int sec = time - (min * 60);
    
    NSString *timeStr = @"";
    if (hours < 10) {
        timeStr = [timeStr stringByAppendingString:@"0"];
    }
    timeStr = [timeStr stringByAppendingFormat:@"%d:", hours];
    
    if (min < 10) {
        timeStr = [timeStr stringByAppendingString:@"0"];
    }
    timeStr = [timeStr stringByAppendingFormat:@"%d:", min];
    
    if (sec < 10) {
        timeStr = [timeStr stringByAppendingString:@"0"];
    }
    timeStr = [timeStr stringByAppendingFormat:@"%d", sec];
    
    return timeStr;
}


@end
