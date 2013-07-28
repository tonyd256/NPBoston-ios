//
//  NPResultCell.m
//  NPBoston
//
//  Created by Tony DiPasquale on 5/1/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPResultCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation NPResultCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
