//
//  NPVerbalViewController.m
//  NPBoston
//
//  Created by Tony DiPasquale on 4/29/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPVerbalViewController.h"
#import "NPVerbalCell.h"
#import "Mixpanel.h"
#import "SVProgressHUD.h"
#import "NPAPIClient.h"
#import "NPVerbal.h"

@interface NPVerbalViewController ()

@end

@implementation NPVerbalViewController {
    NSMutableArray *verbals;
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
    [[Mixpanel sharedInstance] track:@"verbal view loaded"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // get verbals
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getVerbals
{
    if (!self.workout || !self.workout.objectId) return;
    
    [[Mixpanel sharedInstance] track:@"verbals request attempted"];
    [SVProgressHUD showWithStatus:@"Loading..."];
    [[NPAPIClient sharedClient] getPath:[NSString stringWithFormat:@"workouts/%@/verbals", self.workout.objectId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *data = [responseObject valueForKey:@"data"];
        verbals = [[NSMutableArray alloc] init];
        
        for (id object in data) {
            [verbals addObject:[NPVerbal verbalWithObject:object]];
        }
        
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
        [[Mixpanel sharedInstance] track:@"verbals request succeeded"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        verbals = [[NSMutableArray alloc] init];
        AFJSONRequestOperation *op = (AFJSONRequestOperation *)operation;
        NSLog(@"Error: %@", [[op responseJSON] valueForKey:@"error"]);
        [SVProgressHUD dismiss];
        [[Mixpanel sharedInstance] track:@"verbals request failed" properties:@{@"error": [[op responseJSON] valueForKey:@"error"]}];
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
    return [verbals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NPVerbalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VerbalCell" forIndexPath:indexPath];
    
    cell.nameLabel.text = [(NPVerbal *)[verbals objectAtIndex:indexPath.row] name];
    cell.profilePic.profileID = [(NPVerbal *)[verbals objectAtIndex:indexPath.row] fid];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[Mixpanel sharedInstance] track:@"verbal row tapped"];
}

@end
