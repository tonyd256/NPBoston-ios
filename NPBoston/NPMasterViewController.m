//
//  NPMasterViewController.m
//  NPBoston
//
//  Created by Tony DiPasquale on 4/17/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPMasterViewController.h"

#import <FacebookSDK/FacebookSDK.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

#import "NPAppDelegate.h"
#import "NPLoginViewController.h"
#import "NPWorkoutDetailsViewController.h"
#import "NPAPIClient.h"
#import "SVProgressHUD.h"
#import "NSString+FontAwesome.h"
#import "Mixpanel.h"
#import "TestFlight.h"
#import "NPWorkout.h"
#import "NPResult.h"

@interface NPMasterViewController () {
    NSMutableArray *_objects;
    NPUser *user;
    NPWorkout *selectedWorkout;
    NSIndexPath *selectedIndexPath;
}
@end

@implementation NPMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStateChanged:) name:FBSessionStateChangedNotification object:nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults valueForKey:@"user"]) {
        [self performSegueWithIdentifier:@"LoginViewSegue" sender:self];
    }
    
    [[Mixpanel sharedInstance] track:@"master view loaded"];
    
    [[Mixpanel sharedInstance] track:@"workout types request attempted"];
    [[NPAPIClient sharedClient] getPath:@"workout_types" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *types = [responseObject objectForKey:@"data"];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:types forKey:@"types"];
        [defaults synchronize];
        [[Mixpanel sharedInstance] track:@"workout types request succeeded"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [[Mixpanel sharedInstance] track:@"workout types request failed"];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sessionStateChanged:(NSNotification *)notification {
    if (FBSession.activeSession.isOpen) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        [[Mixpanel sharedInstance] track:@"facebook user request attempted"];
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id fbUser, NSError *error) {
            
            if (!error) {
                [[Mixpanel sharedInstance] track:@"facebook user request succeeded"];
                // save user info
                [[Mixpanel sharedInstance] track:@"facebook user login attempted"];
                [[NPAPIClient sharedClient] postPath:@"user/facebook" parameters:@{
                    @"name": [fbUser valueForKey:@"name"],
                    @"fid": [fbUser valueForKey:@"id"],
                    @"email": [fbUser valueForKey:@"email"]}
                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        user = [NPUser userWithObject:[responseObject valueForKey:@"data"]];
                        
                        [defaults setObject:user forKey:@"user"];                        
                        [defaults synchronize];
                        
                        [[Mixpanel sharedInstance] identify:user.objectId];
                        [[[Mixpanel sharedInstance] people] set:@"$name" to:user.name];
                        [[[Mixpanel sharedInstance] people] set:@"$gender" to:[fbUser valueForKey:@"gender"]];
                        [[Mixpanel sharedInstance] track:@"facebook user login succeeded"];
                        
                        [self getWorkouts];
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"Error: %@", error);
                        [[Mixpanel sharedInstance] track:@"facebook user login failed" properties:@{@"error": error.localizedDescription}];
                    }];
                
            } else {
                NSLog(@"FB Error: %@", error);
                [[Mixpanel sharedInstance] track:@"facebook user request failed" properties:@{@"error": error.localizedDescription}];
            }
        }];
    }
}

- (void)userLoggedIn:(NPUser *)u
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:u forKey:@"user"];
    user = u;
    
    [[Mixpanel sharedInstance] identify:user.objectId];
    [[[Mixpanel sharedInstance] people] set:@"$name" to:user.name];
    
    [self getWorkouts];
}

- (void)getWorkouts
{
    [[Mixpanel sharedInstance] track:@"workouts request attempted"];
    [SVProgressHUD showWithStatus:@"Loading..."];
    [[NPAPIClient sharedClient] getPath:@"workouts" parameters:@{@"uid": user.objectId} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *data = [responseObject valueForKey:@"data"];
        _objects = [[NSMutableArray alloc] init];
        
        for (id object in data) {
            [_objects addObject:[NPWorkout workoutWithObject:object]];
        }
        
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
        [[Mixpanel sharedInstance] track:@"workouts request succeeded"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _objects = [[NSMutableArray alloc] init];
        NSLog(@"Error: %@", error);
        [SVProgressHUD dismiss];
        [[Mixpanel sharedInstance] track:@"workouts request failed" properties:@{@"error": error.localizedDescription}];
    }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NPWorkoutCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WorkoutCell"];
    
    if (!cell.delegate) {
        cell.delegate = self;
    }
    
    NPWorkout *workout = _objects[indexPath.row];
    cell.titleLabel.text = workout.title;
    cell.subtitleLabel.text = workout.subtitle;
    
    CLLocationCoordinate2D coor;
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    if (workout.lat) {
        coor.latitude = [workout.lat doubleValue];
        coor.longitude = [workout.lng doubleValue];
        
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        [point setCoordinate:coor];
        [cell.locationMap addAnnotation:point];
        
        span.latitudeDelta = .003;
        span.longitudeDelta = .003;
    } else {
        coor.latitude = 42.358431;
        coor.longitude = -71.059773;
        span.latitudeDelta = .01;
        span.longitudeDelta = .01;
    }
    
    region.center = coor;
    region.span = span;
    [cell.locationMap setRegion:region];
    cell.locationMap.scrollEnabled = NO;
    cell.locationMap.zoomEnabled = NO;
    
    cell.verbalButton.titleLabel.textColor = [UIColor grayColor];
    cell.resultsButton.titleLabel.textColor = [UIColor grayColor];
    
    if (workout.verbal) {
        cell.verbalButton.titleLabel.textColor = [UIColor colorWithRed:(28/255.0) green:(164/255.0) blue:(190/255.0) alpha:1];
    }
    
    if (workout.result) {
        cell.resultsButton.titleLabel.textColor = [UIColor colorWithRed:(28/255.0) green:(164/255.0) blue:(190/255.0) alpha:1];
    }

    cell.workout = workout;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

#pragma mark - NPWorkoutCell Delegate

- (void)showDetailsWithWorkout:(NPWorkout *)workout
{
    selectedWorkout = workout;
    [self performSegueWithIdentifier:@"WorkoutDetailSegue" sender:self];
}

- (void)submitResultsWithIndexPath:(NSIndexPath *)indexPath
{
    selectedWorkout = [_objects objectAtIndex:indexPath.row];
    selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"SubmitResultsSegue" sender:self];
}

#pragma mark - NPResultsSubmit Delegate

- (void)resultsSaved
{
    [(NPWorkoutCell *)[self.tableView cellForRowAtIndexPath:selectedIndexPath] resultsButton].titleLabel.textColor = [UIColor colorWithRed:(28/255.0) green:(164/255.0) blue:(190/255.0) alpha:1];
    
    [[Mixpanel sharedInstance] track:@"workouts request attempted"];
    [[NPAPIClient sharedClient] getPath:@"workouts" parameters:@{@"uid": user.objectId} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *data = [responseObject valueForKey:@"data"];
        [_objects removeAllObjects];
        
        for (id object in data) {
            [_objects addObject:[NPWorkout workoutWithObject:object]];
        }
        
        [self.tableView reloadData];
        [[Mixpanel sharedInstance] track:@"workouts request succeeded"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [[Mixpanel sharedInstance] track:@"workouts request failed" properties:@{@"error": error.localizedDescription}];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"WorkoutDetailSegue"]) {
        NPWorkoutDetailsViewController *view = [segue destinationViewController];
        view.title = selectedWorkout.title;
        view.workout = selectedWorkout;
    } else if ([[segue identifier] isEqualToString:@"SubmitResultsSegue"]) {
        NPSubmitResultsViewController *view = [segue destinationViewController];
        view.workout = selectedWorkout;
        view.delegate = self;
    }
}
@end
