//
//  NPResultCell.m
//  NovProject
//
//  Created by Tony DiPasquale on 5/1/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "NPResultCell.h"

@implementation NPResultCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.cellView.layer.cornerRadius = 3.0;
    self.cellView.layer.borderColor = [UIColor colorWithRed:(170/255.0) green:(170/255.0) blue:(170/255.0) alpha:1].CGColor;
    self.cellView.layer.borderWidth = 0.5;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.cellView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(3.0, 3.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.cellView.layer.mask = maskLayer;
    
    self.topView.layer.borderColor = [UIColor colorWithRed:(170/255.0) green:(170/255.0) blue:(170/255.0) alpha:1].CGColor;
    self.topView.layer.borderWidth = 0.5;
}

@end
