//
//  NSString+Extensions.m
//  NovProject
//
//  Created by Tony DiPasquale on 8/21/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NSString+Extensions.h"

@implementation NSString (Extensions)

- (BOOL)isEmpty
{
    return [[self stringByStrippingWhitespace] isEqualToString:@""];
}

- (NSString *)stringByStrippingWhitespace
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL)containsString:(NSString *)string
{
    NSRange range = [self rangeOfString:string];
    return (range.location != NSNotFound);
}

@end
