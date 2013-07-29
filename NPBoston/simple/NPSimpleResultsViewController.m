//
//  NPSimpleResultsViewController.m
//  NPBoston
//
//  Created by Tony DiPasquale on 7/23/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPSimpleResultsViewController.h"
#import "NPWorkout.h"
#import "NPResult.h"
#import "NPVerbal.h"
#import "NPSimpleResultsCell.h"
#import "NPAPIClient.h"
#import "NPUser.h"
#import "SVProgressHUD.h"
#import "WCAlertView.h"
#import "NPUtils.h"

@interface NPSimpleResultsViewController ()

@property (strong, nonatomic) NSMutableArray *workouts;
@property (strong, nonatomic) NSMutableDictionary *results;
@property (strong, nonatomic) NPUser *user;

@end

@implementation NPSimpleResultsViewController

#pragma mark - View flow

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults objectForKey:@"user"]) {
        [self performSegueWithIdentifier:@"LoginViewSegue" sender:self];
    } else {
        self.user = (NPUser *)[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"user"]];
    }
    
    self.workouts = [[NSMutableArray alloc] init];
    self.results = [[NSMutableDictionary alloc] init];
    
    if (self.user) {
        [self getWorkouts];
    }
    
    [[Mixpanel sharedInstance] track:@"simple results view loaded"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self becomeFirstResponder];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

#pragma mark - NPLoginViewController delegate

- (void)userLoggedIn:(NPUser *)u
{
    self.user = u;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.user] forKey:@"user"];
    [defaults synchronize];
    
    [[Mixpanel sharedInstance] identify:self.user.objectId];
    [[[Mixpanel sharedInstance] people] set:@"$name" to:self.user.name];
    [[[Mixpanel sharedInstance] people] set:@"$gender" to:self.user.gender];
    
    [self getWorkouts];
}

#pragma mark - Populate methods

- (void)getWorkouts
{
    [[Mixpanel sharedInstance] track:@"workouts request attempted"];
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    [[NPAPIClient sharedClient] getPath:@"workouts" parameters:@{@"location": self.user.location, @"limit": @3} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[Mixpanel sharedInstance] track:@"workouts request succeeded"];
        NSArray *wks = [responseObject objectForKey:@"data"];
        [self.workouts removeAllObjects];
        [self.results removeAllObjects];
        
        for (id wk in wks) {
            NPWorkout *workout = [NPWorkout workoutWithObject:wk];
            [self.workouts addObject:workout];
            
            [[Mixpanel sharedInstance] track:@"results request attempted"];
            [[NPAPIClient sharedClient] getPath:[NSString stringWithFormat:@"workouts/%@/results", workout.objectId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [[Mixpanel sharedInstance] track:@"results request succeeded"];
                
                NSArray *response = [responseObject objectForKey:@"data"];
                NSMutableArray *array = [NSMutableArray arrayWithCapacity:[response count]];
                for (id result in response) {
                    [array addObject:[NPResult resultWithObject:result]];
                }
                
                [self.results setObject:array forKey:workout.objectId];
                [self.tableView reloadData];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [NPUtils reportError:error WithMessage:@"results request failed" FromOperation:(AFJSONRequestOperation *)operation];
            }];
        }
        [SVProgressHUD dismiss];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *msg = [NPUtils reportError:error WithMessage:@"workouts request failed" FromOperation:(AFJSONRequestOperation *)operation];
        [SVProgressHUD dismiss];
        
        [[[UIAlertView alloc] initWithTitle:@"Error Occured" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.workouts count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ([self.results count] > section) {
        NPWorkout *workout = [self.workouts objectAtIndex:section];
        return [[self.results objectForKey:workout.objectId] count];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NPWorkout *wk = [self.workouts objectAtIndex:section];
    
    return wk.title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SimpleResultCell";
    NPSimpleResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NPWorkout *wk = [self.workouts objectAtIndex:indexPath.section];
    NPResult *result = (NPResult *)[[self.results objectForKey:wk.objectId] objectAtIndex:indexPath.row];
    
    [cell.nameLabel setText:result.userName];
    [cell.amountLabel setText:[result.amount stringValue]];
    [cell.timeLabel setText:[NPUtils timeToString:result.time]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - NPResultsSubmit Delegate

- (void)resultsSaved
{    
    [self getWorkouts];
}

#pragma mark - Handle shake

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.subtype == UIEventSubtypeMotionShake) {
        [WCAlertView showAlertWithTitle:@"Unlock?" message:@"Unlock and use the beta version?" customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
            if (buttonIndex == 0) {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setBool:YES forKey:@"unlocked"];
                [defaults synchronize];
                
                [[[UIAlertView alloc] initWithTitle:@"Restart the App!" message:@"Exit the app then double click the home button.  Hold down the app icon and click the red circle." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        } cancelButtonTitle:@"No" otherButtonTitles:@"Yes!", nil];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - Actions methods

- (IBAction)recordResultsAction:(id)sender
{
    if ([self.workouts count] == 0) {
        return;
    }
    
    [self performSegueWithIdentifier:@"SubmitResultsSegue" sender:self];
}

- (IBAction)viewDetailsAction:(id)sender
{
    if ([self.workouts count] == 0) {
        return;
    }
}

- (IBAction)giveVerbalAction:(id)sender
{
    if ([self.workouts count] == 0) {
        return;
    }
    
    NPWorkout *workout = [self.workouts objectAtIndex:0];
    // if the current date is sooner than the workout date
    if ([[NSDate date] timeIntervalSince1970] < [workout.date timeIntervalSince1970]) {
        // make request to server for verbal
        if (!workout.verbal) {            
            [[Mixpanel sharedInstance] track:@"verbal attempted"];
            [SVProgressHUD showWithStatus:@"Committing..."];
            
            NSString *url = [NSString stringWithFormat:@"workouts/%@/verbal", workout.objectId];
            [[NPAPIClient sharedClient] postPath:url parameters:@{@"uid": self.user.objectId, @"name": self.user.name} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [[Mixpanel sharedInstance] track:@"verbal succeeded"];
                workout.verbal = [NPVerbal verbalWithObject:[responseObject objectForKey:@"data"]];
                [SVProgressHUD dismiss];
                
                [[[UIAlertView alloc] initWithTitle:@"See You There!" message:@"You can back out up to 6 hours before the workout begins." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSString *msg = [NPUtils reportError:error WithMessage:@"verbal failed" FromOperation:(AFJSONRequestOperation *)operation];
                [SVProgressHUD dismiss];
                [[[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }];
        } else if ([[NSDate date] timeIntervalSince1970] < ([workout.date timeIntervalSince1970] - 32400)) {
            [[Mixpanel sharedInstance] track:@"verbal removal attempted"];
            [SVProgressHUD showWithStatus:@"Uncommitting..."];
            
            NSString *url = [NSString stringWithFormat:@"workouts/%@/verbal", workout.objectId];
            [[NPAPIClient sharedClient] deletePath:url parameters:@{@"uid": self.user.objectId} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [[Mixpanel sharedInstance] track:@"verbal removal succeeded"];
                workout.verbal = nil;
                [SVProgressHUD dismiss];
                
                [[[UIAlertView alloc] initWithTitle:@"You Backed Out" message:@"We'll catch you next time!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSString *msg = [NPUtils reportError:error WithMessage:@"verbal removal failed" FromOperation:(AFJSONRequestOperation *)operation];
                [SVProgressHUD dismiss];
                [[[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }];
        } else if ([[NSDate date] timeIntervalSince1970] > ([workout.date timeIntervalSince1970] - 21600) && [[NSDate date] timeIntervalSince1970] < [workout.date timeIntervalSince1970]) {
            [[[UIAlertView alloc] initWithTitle:@"Nice Try" message:@"You can't take back a verbal within 6 hours of the workout!" delegate:nil cancelButtonTitle:@"I'll Be There!" otherButtonTitles:nil] show];
        }
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Nice Try" message:@"This workout has passed. You can't retroactively give a verbal!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

#pragma mark - Overridden methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SubmitResultsSegue"]) {
        NPSubmitResultsViewController *view = [segue destinationViewController];
        view.workout = [self.workouts objectAtIndex:0];
        view.delegate = self;
    } else if ([[segue identifier] isEqualToString:@"LoginViewSegue"]) {
        NPLoginViewController *view = [segue destinationViewController];
        view.delegate = self;
    }
}
@end
