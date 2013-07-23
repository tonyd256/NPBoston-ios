//
//  NPResultsViewController.m
//  NPBoston
//
//  Created by Tony DiPasquale on 5/1/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPResultsViewController.h"
#import "Mixpanel.h"
#import "SVProgressHUD.h"
#import "NPAPIClient.h"
#import "NPResult.h"
#import "NPResultCell.h"

@interface NPResultsViewController ()

@end

@implementation NPResultsViewController {
    NSMutableArray *results;
}

@synthesize workout = _workout;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getResults];
    
    [[Mixpanel sharedInstance] track:@"results view loaded"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.parentViewController.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getResults
{
    if (!self.workout || !self.workout.objectId) return;
    
    [[Mixpanel sharedInstance] track:@"results request attempted"];
    [SVProgressHUD showWithStatus:@"Loading..."];
    [[NPAPIClient sharedClient] getPath:[NSString stringWithFormat:@"workouts/%@/results", self.workout.objectId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *data = [responseObject valueForKey:@"data"];
        results = [[NSMutableArray alloc] init];
        
        for (id object in data) {
            [results addObject:[NPResult resultWithObject:object]];
        }
        
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
        [[Mixpanel sharedInstance] track:@"results request succeeded"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        results = [[NSMutableArray alloc] init];
        AFJSONRequestOperation *op = (AFJSONRequestOperation *)operation;
        NSLog(@"Error: %@", [[op responseJSON] valueForKey:@"error"]);
        [SVProgressHUD dismiss];
        [[Mixpanel sharedInstance] track:@"results request failed" properties:@{@"error": [[op responseJSON] valueForKey:@"error"]}];
        
        [[[UIAlertView alloc] initWithTitle:@"Error Occured" message:[[op responseJSON] valueForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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
    return results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NPResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultCell" forIndexPath:indexPath];
    NPResult *result = [results objectAtIndex:indexPath.row];
    
    cell.pictureView.profileID = result.uid;
    cell.nameLabel.text = result.userName;
    
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
        NSString *timeStr = [NPResult timeToString:result.time];
        
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
    NPResult *result = [results objectAtIndex:indexPath.row];
    
    if ([result.comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) return 118;
    
    return [result.comment sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(260, 999) lineBreakMode:NSLineBreakByWordWrapping].height + 136;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[Mixpanel sharedInstance] track:@"result row tapped"];
}

@end
