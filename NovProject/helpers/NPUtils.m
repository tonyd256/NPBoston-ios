//
//  NPUtils.m
//  NovProject
//
//  Created by Tony DiPasquale on 7/23/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPUtils.h"
#import "NPAPIClient.h"

@implementation NPUtils

#pragma mark - Error Handling

+ (NSString *)reportError:(NSError *)error WithMessage:(NSString *)message FromOperation:(AFJSONRequestOperation *)operation {
    
    NSString *errorMessage;
    
    if ([operation responseJSON] && [[operation responseJSON] objectForKey:@"error"]) {
        errorMessage = [[operation responseJSON] valueForKey:@"error"];
        NSLog(@"Error: %@", errorMessage);
        [NPAnalytics track:message properties:@{@"error": errorMessage}];
        return errorMessage;
    } else {
        return [self reportError:error WithMessage:message];
    }  
}

+ (NSString *)reportError:(NSError *)error WithMessage:(NSString *)message{
    NSLog(@"Error: %@", error.localizedDescription);
    [NPAnalytics track:message properties:@{@"error": error.localizedDescription}];
    return error.localizedDescription;
}

#pragma mark - Time Formatting

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
