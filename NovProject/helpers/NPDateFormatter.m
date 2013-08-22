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

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    self.displayFormatter = [[NSDateFormatter alloc] init];
    [self.displayFormatter setDateFormat:kDisplayDateFormat];
    [self.displayFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    self.serverFormatter = [[NSDateFormatter alloc] init];
    [self.serverFormatter setDateFormat:kServerDateFormat];
    [self.serverFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    return self;
}

@end
