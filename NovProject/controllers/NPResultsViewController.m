//
//  NPResultsViewController.m
//  NPBoston
//
//  Created by Tony DiPasquale on 5/1/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "NPResultsViewController.h"
#import "SVProgressHUD.h"
#import "NPAPIClient.h"
#import "NPResult.h"
#import "NPResultCell.h"
#import "NPWorkout.h"
#import "NPUtils.h"

@interface NPResultsViewController ()

@property (strong, nonatomic) NSMutableArray *results;

@end

@implementation NPResultsViewController

#pragma mark - View flow

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.results = [[NSMutableArray alloc] init];
    [self getResults];
    
    [[NPAnalytics sharedAnalytics] track:@"results view loaded"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.parentViewController.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - Populate data

- (void)getResults
{
    if (!self.workout || !self.workout.objectId) return;
    
    [[NPAnalytics sharedAnalytics] track:@"results request attempted"];
    [SVProgressHUD showWithStatus:@"Loading..."];
    [[NPAPIClient sharedClient] getPath:[NSString stringWithFormat:@"workouts/%@/results", self.workout.objectId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *data = [responseObject valueForKey:@"data"];
        [self.results removeAllObjects];
        
        for (id object in data) {
            [self.results addObject:[NPResult resultWithObject:object]];
        }
        
        [self.tableView reloadData];
        [[NPAnalytics sharedAnalytics] track:@"results request succeeded"];
        [SVProgressHUD dismiss];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *msg = [NPUtils reportError:error WithMessage:@"results request failed" FromOperation:(AFJSONRequestOperation *)operation];
        [SVProgressHUD dismiss];
        
        [[[UIAlertView alloc] initWithTitle:@"Error Occured" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NPResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultCell" forIndexPath:indexPath];
    NPResult *result = [self.results objectAtIndex:indexPath.row];
    
    cell.pictureView.profileID = result.uid;
    cell.nameLabel.text = result.name;
    
    NSString *str = @"";
    
    if ([result.type isEqualToString:@"Other"]) {
        str = [str stringByAppendingString:result.type];
    } else if ([result.type isEqualToString:@"Deck"]) {
        if ([result.amount integerValue] <= 1) {
            str = [str stringByAppendingString:@"One Deck"];
        } else {
            str = [str stringByAppendingFormat:@"%@ %@s", result.amount, result.type];
        }
    } else {
        str = [str stringByAppendingFormat:@"%@ %@", result.amount, result.type];
    }
    
    if ([result.time integerValue] != 0) {
        NSString *timeStr = [NPUtils timeToString:result.time];
        
        if ([[timeStr substringToIndex:2] isEqualToString:@"00"]) {
            str = [str stringByAppendingFormat:@" in %@", [timeStr substringFromIndex:3]];
        } else {
            str = [str stringByAppendingFormat:@" in %@", timeStr];
        }
        
    }
    
    if ([result.pr isEqualToString:@"YES"]) {
        str = [str stringByAppendingString:@" (PR)"];
    }
    
    cell.resultLabel.text = str;
    
    if ([result.comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        cell.commentsLabel.hidden = YES;
        [cell.cellView setFrame:CGRectMake(cell.cellView.frame.origin.x, cell.cellView.frame.origin.y, cell.cellView.frame.size.width, 100)];
    } else {
        cell.commentsLabel.hidden = NO;
        cell.commentsText.text = result.comment;
        cell.commentsText.contentInset = UIEdgeInsetsMake(-8,0,0,0);
        
        int h = [result.comment sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(260, 999) lineBreakMode:NSLineBreakByWordWrapping].height;
        
        [cell.commentsText setFrame:CGRectMake(cell.commentsText.frame.origin.x, cell.commentsText.frame.origin.y, cell.commentsText.frame.size.width, h)];
        
        [cell.cellView setFrame:CGRectMake(cell.cellView.frame.origin.x, cell.cellView.frame.origin.y, cell.cellView.frame.size.width, 120 + h)];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NPResult *result = [self.results objectAtIndex:indexPath.row];
    
    if ([result.comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) return 118;
    
    return [result.comment sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(260, 999) lineBreakMode:NSLineBreakByWordWrapping].height + 136;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NPAnalytics sharedAnalytics] track:@"result row tapped"];
}

@end
