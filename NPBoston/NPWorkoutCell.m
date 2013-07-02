//
//  NPWorkoutCell.m
//  NPBoston
//
//  Created by Tony DiPasquale on 4/18/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPWorkoutCell.h"
#import <QuartzCore/QuartzCore.h>
#import "TTTAttributedLabel.h"
#import "NSString+FontAwesome.h"
#import "NPAPIClient.h"
#import "WCAlertView.h"
#import "Mixpanel.h"

@implementation NPWorkoutCell

@synthesize titleLabel = _titleLabel;
@synthesize subtitleLabel = _subtitleLabel;
@synthesize verbalButton = _verbalButton;
@synthesize locationMap = _locationMap;
@synthesize resultsButton = _resultsButton;
@synthesize cellView = _cellView;
@synthesize topView = _topView;
@synthesize workout = _workout;
@synthesize userID = _userID;
@synthesize userName = _userName;

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
    self.locationMap.layer.borderColor = [UIColor colorWithRed:(170/255.0) green:(170/255.0) blue:(170/255.0) alpha:1].CGColor;
    self.locationMap.layer.borderWidth = 0.5;
    
    UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapView.numberOfTapsRequired = 1;
    [self.topView addGestureRecognizer:tapView];
    
    UITapGestureRecognizer *tapMap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapTapped:)];
    tapMap.numberOfTapsRequired = 1;
    [self.locationMap addGestureRecognizer:tapMap];
    
    NSMutableAttributedString *verbalString = [[NSMutableAttributedString alloc] initWithString:[[NSString fontAwesomeIconStringForEnum:FAIconOk] stringByAppendingString:@" Verbal"]];
    [verbalString addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontAwesomeFamilyName size:12] range:NSMakeRange(0, [[NSString fontAwesomeIconStringForEnum:FAIconOk] length])];
    [self.verbalButton setAttributedTitle:verbalString forState:UIControlStateNormal];
    
    NSMutableAttributedString *resultsString = [[NSMutableAttributedString alloc] initWithString:[[NSString fontAwesomeIconStringForEnum:FAIconEdit] stringByAppendingString:@" Results"]];
    [resultsString addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontAwesomeFamilyName size:12] range:NSMakeRange(0, [[NSString fontAwesomeIconStringForEnum:FAIconEdit] length])];
    [self.resultsButton setAttributedTitle:resultsString forState:UIControlStateNormal];
    
    NSMutableAttributedString *webString = [[NSMutableAttributedString alloc] initWithString:[[NSString fontAwesomeIconStringForEnum:FAIconGlobe] stringByAppendingString:@" Web"]];
    [webString addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontAwesomeFamilyName size:12] range:NSMakeRange(0, [[NSString fontAwesomeIconStringForEnum:FAIconGlobe] length])];
    [self.webButton setAttributedTitle:webString forState:UIControlStateNormal];
    self.webButton.titleLabel.textColor = [UIColor grayColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)resultsButtonAction:(UIButton *)sender
{
    if ([[NSDate date] timeIntervalSince1970] < [self.workout.date integerValue]) {
        [WCAlertView showAlertWithTitle:@"Hold On!" message:@"You are trying to post a workout result before the workout has started.  Are you sure you want to do this?" customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
            if (buttonIndex == 0) {
                [self.delegate submitResultsWithIndexPath:[(UITableView *)self.superview indexPathForCell:self]];
                [[Mixpanel sharedInstance] track:@"result post early attempted"];
            }
        } cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    } else {
        [self.delegate submitResultsWithIndexPath:[(UITableView *)self.superview indexPathForCell:self]];
    }
}

- (IBAction)verbalButtonAction:(UIButton *)sender
{
    if ([[NSDate date] timeIntervalSince1970] < [self.workout.date integerValue]) {
        // make request to server for verbal
        if ([self.verbalButton.titleLabel.textColor isEqual:[UIColor grayColor]]) {
            self.verbalButton.titleLabel.textColor = [UIColor colorWithRed:(28/255.0) green:(164/255.0) blue:(190/255.0) alpha:1];
            
            [[Mixpanel sharedInstance] track:@"verbal attempted"];
            
            NSString *url = [NSString stringWithFormat:@"workouts/%@/verbal", self.workout.objectId];
            [[NPAPIClient sharedClient] postPath:url parameters:@{@"uid": self.userID, @"name": self.userName} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if ([responseObject valueForKey:@"data"] == 0) {
                    self.verbalButton.titleLabel.textColor = [UIColor grayColor];
                    [[Mixpanel sharedInstance] track:@"verbal failed" properties:@{@"error": @"server side"}];
                } else {
                    [[Mixpanel sharedInstance] track:@"verbal succeeded"];
                    NSMutableDictionary *verbal = [[NSMutableDictionary alloc] init];
                    [verbal setValue:self.userID forKey:@"uid"];
                    [verbal setValue:self.userName forKey:@"name"];
                    [self.workout.verbals addObject:verbal];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                self.verbalButton.titleLabel.textColor = [UIColor grayColor];
                [[Mixpanel sharedInstance] track:@"verbal failed" properties:@{@"error": error.localizedDescription}];
            }];
        } else if ([[NSDate date] timeIntervalSince1970] < ([self.workout.date integerValue] - 32400)) {
            self.verbalButton.titleLabel.textColor = [UIColor grayColor];
            
            [[Mixpanel sharedInstance] track:@"verbal removal attempted"];
            
            NSString *url = [NSString stringWithFormat:@"workouts/%@/verbal", self.workout.objectId];
            [[NPAPIClient sharedClient] deletePath:url parameters:@{@"uid": self.userID} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if ([responseObject valueForKey:@"data"] == 0) {
                    self.verbalButton.titleLabel.textColor = [UIColor colorWithRed:(28/255.0) green:(164/255.0) blue:(190/255.0) alpha:1];
                    [[Mixpanel sharedInstance] track:@"verbal removal failed" properties:@{@"error": @"server side"}];
                } else {
                    [[Mixpanel sharedInstance] track:@"verbal removal succeeded"];
                    
                    for (NSMutableDictionary *dict in self.workout.verbals) {
                        if ([[dict valueForKey:@"uid"] isEqualToString:self.userID]) {
                            [self.workout.verbals removeObject:dict];
                            break;
                        }
                    }
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                self.verbalButton.titleLabel.textColor = [UIColor colorWithRed:(28/255.0) green:(164/255.0) blue:(190/255.0) alpha:1];
                [[Mixpanel sharedInstance] track:@"verbal removal failed" properties:@{@"error": error.localizedDescription}];
            }];
        } else if ([[NSDate date] timeIntervalSince1970] > ([self.workout.date integerValue] - 32400) && [[NSDate date] timeIntervalSince1970] < [self.workout.date integerValue]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nice Try" message:@"You can't take back a verbal within 9 hours of the workout!" delegate:nil cancelButtonTitle:@"I'll Be There!" otherButtonTitles:nil];
            [alert show];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nice Try" message:@"This workout has passed. You can't retroactively give a verbal!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)webButtonAction:(UIButton *)sender
{
    // open to url link
    NSURL *url;
    if (self.workout.url) {
        url = [NSURL URLWithString:self.workout.url];
    } else {
        url = [NSURL URLWithString:@"http://november-project.com/category/blog/"];
    }
    
    [[Mixpanel sharedInstance] track:@"web tapped"];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)viewTapped:(UITapGestureRecognizer *)sender
{
    [self.delegate showDetailsWithWorkout:self.workout];
}

- (void)mapTapped:(UITapGestureRecognizer *)sender
{
    [[Mixpanel sharedInstance] track:@"map tapped"];
    if (self.workout.lat) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.apple.com/?q=%f,%f", [self.workout.lat floatValue], [self.workout.lng floatValue]]];
            [[UIApplication sharedApplication] openURL:url];
        } else {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/?q=%f,%f", [self.workout.lat floatValue], [self.workout.lng floatValue]]];
            [[UIApplication sharedApplication] openURL:url];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"The location hasn't been posted yet." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}
@end
