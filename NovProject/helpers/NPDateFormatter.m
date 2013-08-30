//
//  NPDateFormatter.m
//  NovProject
//
//  Created by Tony DiPasquale on 8/19/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPDateFormatter.h"

static NSString * const kDisplayDateFormat = @"E - MMM dd, yyyy - h:mma";
static NSString * const kServerDateFormat = @"yyyy-MM-dd'T'HH:mm";

@implementation NPDateFormatter

+ (NPDateFormatter *)sharedFormatter
{
    static NPDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NPDateFormatter alloc] init];
    });
    return formatter;
}

- (NSDateFormatter *)displayFormatter
{
    if (!_displayFormatter) {
        _displayFormatter = [[NSDateFormatter alloc] init];
        [_displayFormatter setDateFormat:kDisplayDateFormat];
        [_displayFormatter setTimeZone:[NSTimeZone localTimeZone]];
    }
    return _displayFormatter;
}

- (NSDateFormatter *)serverFormatter
{
    if (!_serverFormatter) {
        _serverFormatter = [[NSDateFormatter alloc] init];
        [_serverFormatter setDateFormat:kServerDateFormat];
        [_serverFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    return _serverFormatter;
}

@end
