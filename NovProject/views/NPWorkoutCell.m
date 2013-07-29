//
//  NPWorkoutCell.m
//  NPBoston
//
//  Created by Tony DiPasquale on 4/18/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>

#import "NPWorkoutCell.h"
#import "NSString+FontAwesome.h"
#import "NPAPIClient.h"
#import "WCAlertView.h"
#import "NPWorkout.h"
#import "NPVerbal.h"
#import "NPUtils.h"

@implementation NPWorkoutCell

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
    
    self.actionsView.layer.borderColor = [UIColor colorWithRed:(170/255.0) green:(170/255.0) blue:(170/255.0) alpha:1].CGColor;
    self.actionsView.layer.borderWidth = 0.5;
    self.locationMap.layer.borderColor = [UIColor colorWithRed:(170/255.0) green:(170/255.0) blue:(170/255.0) alpha:1].CGColor;
    self.locationMap.layer.borderWidth = 0.5;
    
    UITapGestureRecognizer *tapMap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapTapped:)];
    tapMap.numberOfTapsRequired = 1;
    [self.locationMap addGestureRecognizer:tapMap];
    
    NSMutableAttributedString *verbalString = [[NSMutableAttributedString alloc] initWithString:[[NSString fontAwesomeIconStringForEnum:FAIconOk] stringByAppendingString:@" Commit"]];
    [verbalString addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontAwesomeFamilyName size:12] range:NSMakeRange(0, [[NSString fontAwesomeIconStringForEnum:FAIconOk] length])];
    [self.verbalButton setAttributedTitle:verbalString forState:UIControlStateNormal];
    
    NSMutableAttributedString *resultsString = [[NSMutableAttributedString alloc] initWithString:[[NSString fontAwesomeIconStringForEnum:FAIconEdit] stringByAppendingString:@" Record"]];
    [resultsString addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontAwesomeFamilyName size:12] range:NSMakeRange(0, [[NSString fontAwesomeIconStringForEnum:FAIconEdit] length])];
    [self.resultsButton setAttributedTitle:resultsString forState:UIControlStateNormal];
}

- (IBAction)resultsButtonAction:(UIButton *)sender
{
    if ([[NSDate date] timeIntervalSince1970] < [self.workout.date timeIntervalSince1970]) {
        [WCAlertView showAlertWithTitle:@"Hold On!" message:@"You are trying to post a workout result before the workout has started.  Are you sure you want to do this?" customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
            if (buttonIndex == 0) {
                if (self.delegate)
                    [self.delegate submitResultsWithIndexPath:[(UITableView *)self.superview indexPathForCell:self]];
                [[Mixpanel sharedInstance] track:@"result post early attempted"];
            }
        } cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    } else {
        if (self.delegate)
            [self.delegate submitResultsWithIndexPath:[(UITableView *)self.superview indexPathForCell:self]];
    }
}

- (IBAction)verbalButtonAction:(UIButton *)sender
{
    // if the current date is sooner than the workout date
    if ([[NSDate date] timeIntervalSince1970] < [self.workout.date timeIntervalSince1970]) {
        // make request to server for verbal
        if ([self.verbalButton.titleLabel.textColor isEqual:[UIColor grayColor]]) {
            self.verbalButton.titleLabel.textColor = [UIColor colorWithRed:(28/255.0) green:(164/255.0) blue:(190/255.0) alpha:1];
            
            [[Mixpanel sharedInstance] track:@"verbal attempted"];
            
            NSString *url = [NSString stringWithFormat:@"workouts/%@/verbal", self.workout.objectId];
            [[NPAPIClient sharedClient] postPath:url parameters:@{@"uid": self.userID, @"name": self.userName} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [[Mixpanel sharedInstance] track:@"verbal succeeded"];
                self.workout.verbal = [NPVerbal verbalWithObject:[responseObject objectForKey:@"data"]];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSString *msg = [NPUtils reportError:error WithMessage:@"verbals request failed" FromOperation:(AFJSONRequestOperation *)operation];
                self.verbalButton.titleLabel.textColor = [UIColor grayColor];
                [[[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }];
        } else if ([[NSDate date] timeIntervalSince1970] < ([self.workout.date timeIntervalSince1970] - 32400)) {
            self.verbalButton.titleLabel.textColor = [UIColor grayColor];
            
            [[Mixpanel sharedInstance] track:@"verbal removal attempted"];
            
            NSString *url = [NSString stringWithFormat:@"workouts/%@/verbal", self.workout.objectId];
            [[NPAPIClient sharedClient] deletePath:url parameters:@{@"uid": self.userID} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [[Mixpanel sharedInstance] track:@"verbal removal succeeded"];
                self.workout.verbal = nil;
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSString *msg = [NPUtils reportError:error WithMessage:@"verbals request failed" FromOperation:(AFJSONRequestOperation *)operation];
                self.verbalButton.titleLabel.textColor = [UIColor colorWithRed:(28/255.0) green:(164/255.0) blue:(190/255.0) alpha:1];
                [[[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }];
        } else if ([[NSDate date] timeIntervalSince1970] > ([self.workout.date timeIntervalSince1970] - 21600) && [[NSDate date] timeIntervalSince1970] < [self.workout.date timeIntervalSince1970]) {
            [[[UIAlertView alloc] initWithTitle:@"Nice Try" message:@"You can't take back a verbal within 6 hours of the workout!" delegate:nil cancelButtonTitle:@"I'll Be There!" otherButtonTitles:nil] show];
        }
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Nice Try" message:@"This workout has passed. You can't retroactively give a verbal!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (IBAction)viewResultsAction:(id)sender
{
    [[Mixpanel sharedInstance] track:@"results tapped"];
    if (self.delegate)
        [self.delegate showResultsWithWorkout:self.workout];
}

- (IBAction)viewVerbalsAction:(id)sender
{
    [[Mixpanel sharedInstance] track:@"verbals tapped"];
    if (self.delegate)
        [self.delegate showVerbalsWithWorkout:self.workout];
}

- (void)mapTapped:(UITapGestureRecognizer *)sender
{
    [[Mixpanel sharedInstance] track:@"map tapped"];
    if (self.delegate)
        [self.delegate showMapWithWorkout:self.workout];
}
@end
