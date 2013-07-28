//
//  NPResult.m
//  NPBoston
//
//  Created by Tony DiPasquale on 5/1/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPResult.h"

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
        _time = [NPResult stringToTime:[object valueForKey:@"time"]];
    } else {
        _time = [object valueForKey:@"time"];
    }
    
    _amount = [object valueForKey:@"amount"];
    _pr = [object valueForKey:@"pr"];
    _comment = [object valueForKey:@"comment"];
    
    return self;
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
