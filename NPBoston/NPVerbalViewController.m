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

@interface NPVerbalViewController ()

@end

@implementation NPVerbalViewController

@synthesize verbals = _verbals;

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
    self.parentViewController.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    cell.nameLabel.text = [[self.verbals objectAtIndex:indexPath.row] valueForKey:@"name"];
    cell.profilePic.profileID = [[self.verbals objectAtIndex:indexPath.row] valueForKey:@"uid"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[Mixpanel sharedInstance] track:@"verbal row tapped"];
}

@end
