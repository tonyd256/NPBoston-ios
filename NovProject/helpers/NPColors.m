//
//  NPColors.m
//  NovProject
//
//  Created by Tony DiPasquale on 8/21/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPColors.h"

@implementation NPColors

static UIColor *_npBlue;

+ (UIColor *)NPBlue
{
    if (!_npBlue) {
        _npBlue = [UIColor colorWithRed:(28/255.0) green:(164/255.0) blue:(190/255.0) alpha:1];
    }
    return _npBlue;
}

@end
