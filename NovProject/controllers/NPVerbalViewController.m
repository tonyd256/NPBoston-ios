//
//  NPVerbalViewController.m
//  NovProject
//
//  Created by Tony DiPasquale on 4/29/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "NPVerbalViewController.h"
#import "NPVerbalCell.h"
#import "SVProgressHUD.h"
#import "NPAPIClient.h"
#import "NPVerbal.h"
#import "NPWorkout.h"
#import "NPUtils.h"

@interface NPVerbalViewController ()

@property (strong, nonatomic) NSMutableArray *verbals;

@end

@implementation NPVerbalViewController

#pragma mark - View flow

- (void)viewDidLoad
{
    [super viewDidLoad];
    [NPAnalytics track:@"verbal view loaded"];
    self.verbals = [[NSMutableArray alloc] init];
    
    // get verbals
    [self getVerbals];
}

#pragma mark - Populate data

- (void)getVerbals
{
    if (!self.workout || !self.workout.objectId) return;
    
    [NPAnalytics track:@"verbals request attempted"];
    [SVProgressHUD showWithStatus:@"Loading..."];
    [[NPAPIClient sharedClient] getPath:[NSString stringWithFormat:@"workouts/%@/verbals", self.workout.objectId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *data = [responseObject valueForKey:@"data"];
        
        [self.verbals removeAllObjects];
        
        for (id object in data) {
            [self.verbals addObject:[NPVerbal verbalWithObject:object]];
        }
        
        [self.tableView reloadData];
        [NPAnalytics track:@"verbals request succeeded"];
        [SVProgressHUD dismiss];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *msg = [NPUtils reportError:error WithMessage:@"verbals request failed" FromOperation:(AFJSONRequestOperation *)operation];
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
    return [self.verbals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NPVerbalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VerbalCell" forIndexPath:indexPath];
    
    cell.nameLabel.text = [(NPVerbal *)[self.verbals objectAtIndex:indexPath.row] name];
    cell.profilePic.profileID = [(NPVerbal *)[self.verbals objectAtIndex:indexPath.row] fid];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [NPAnalytics track:@"verbal row tapped"];
}

@end
