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
#import "NPResultsViewController.h"
#import "NPVerbalViewController.h"
#import "NPMapViewController.h"
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
    NSDateFormatter *dateFormatter;
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
    
    if (![defaults objectForKey:@"user"]) {
        [self performSegueWithIdentifier:@"LoginViewSegue" sender:self];
    } else {
        user = (NPUser *)[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"user"]];
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
        AFJSONRequestOperation *op = (AFJSONRequestOperation *)operation;
        NSLog(@"Error: %@", [[op responseJSON] valueForKey:@"error"]);
        [[Mixpanel sharedInstance] track:@"workout types request failed" properties:@{@"error": [[op responseJSON] valueForKey:@"error"]}];
    }];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"E - MMM dd, yyyy - hh:mma"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    if (user) {
        [self getWorkouts];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sessionStateChanged:(NSNotification *)notification {
    if (FBSession.activeSession.isOpen) {
        [[NPAPIClient sharedClient] postPath:@"users/facebook" parameters:@{
            @"access_token": FBSession.activeSession.accessTokenData.accessToken}
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NPUser *u = [NPUser userWithObject:[responseObject objectForKey:@"data"]];
                
                [[NPAPIClient sharedClient] setToken:[[responseObject objectForKey:@"data"] valueForKey:@"token"]];
                
                [[Mixpanel sharedInstance] track:@"facebook user login succeeded"];
                [self userLoggedIn:u];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                AFJSONRequestOperation *op = (AFJSONRequestOperation *)operation;
                NSLog(@"Error: %@", [[op responseJSON] valueForKey:@"error"]);
                [[Mixpanel sharedInstance] track:@"facebook user login failed" properties:@{@"error": [[op responseJSON] valueForKey:@"error"]}];
                
                [[[UIAlertView alloc] initWithTitle:@"Error Occured" message:[[op responseJSON] valueForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }];
    }
}

- (void)userLoggedIn:(NPUser *)u
{
    user = u;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:user] forKey:@"user"];
    [defaults synchronize];
    
    [[Mixpanel sharedInstance] identify:user.objectId];
    [[[Mixpanel sharedInstance] people] set:@"$name" to:user.name];
    [[[Mixpanel sharedInstance] people] set:@"$gender" to:user.gender];
    
    [self getWorkouts];
}

- (void)getWorkouts
{
    [[Mixpanel sharedInstance] track:@"workouts request attempted"];
    [SVProgressHUD showWithStatus:@"Loading..."];
    [[NPAPIClient sharedClient] getPath:@"workouts" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
        AFJSONRequestOperation *op = (AFJSONRequestOperation *)operation;
        NSLog(@"Error: %@", [[op responseJSON] valueForKey:@"error"]);
        [SVProgressHUD dismiss];
        [[Mixpanel sharedInstance] track:@"workouts request failed" properties:@{@"error": [[op responseJSON] valueForKey:@"error"]}];
        
        [[[UIAlertView alloc] initWithTitle:@"Error Occured" message:[[op responseJSON] valueForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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
    [cell.titleLabel setText:workout.title];
    [cell.subtitleLabel setText:[dateFormatter stringFromDate:workout.date]];
    
    if ([workout.details stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        [cell.detailsLabel setHidden:YES];
        
        [cell.cellView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(6)-[titleLabel]-(2)-[subtitleLabel]-(210)-(<=6)-[viewVerbalsButton][actionsView(==44)]|" options:0 metrics:nil views:@{@"titleLabel": cell.titleLabel, @"subtitleLabel": cell.subtitleLabel, @"actionsView": cell.actionsView, @"viewVerbalsButton": cell.viewVerbalsButton}]];
    } else {
        [cell.detailsLabel setHidden:NO];
        [cell.detailsLabel setText:workout.details];
        
        int h = [workout.details sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(240, 999) lineBreakMode:NSLineBreakByWordWrapping].height;
        
        [cell.cellView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(6)-[titleLabel]-(2)-[subtitleLabel]-(210)-[detailsLabel(==%d)]-(<=6)-[viewVerbalsButton][actionsView(==44)]|", h] options:0 metrics:nil views:@{@"titleLabel": cell.titleLabel, @"subtitleLabel": cell.subtitleLabel, @"detailsLabel": cell.detailsLabel, @"actionsView": cell.actionsView, @"viewVerbalsButton": cell.viewVerbalsButton}]];
    }
    
    [cell.actionsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[verbalButton(==44)]|" options:0 metrics:nil views:@{@"verbalButton": cell.verbalButton}]];
    
    CLLocationCoordinate2D coor;
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    if (workout.lat) {
        coor.latitude = [workout.lat doubleValue];
        coor.longitude = [workout.lng doubleValue];
        
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        [point setCoordinate:coor];
        [cell.locationMap addAnnotation:point];
        
        span.latitudeDelta = .02;
        span.longitudeDelta = .02;
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
    
    [cell.viewVerbalsButton setTitle:[NSString stringWithFormat:@"(%d) Verbals", [workout.verbalsCount integerValue]] forState:UIControlStateNormal];
    [cell.viewResultsButton setTitle:[NSString stringWithFormat:@"(%d) Results", [workout.resultsCount integerValue]] forState:UIControlStateNormal];
    
    [cell.verbalButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [cell.resultsButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    if (workout.verbal) {
        [cell.verbalButton setTitleColor:[UIColor colorWithRed:(28/255.0) green:(164/255.0) blue:(190/255.0) alpha:1] forState:UIControlStateNormal];
    }
    
    if (workout.result) {
        [cell.resultsButton setTitleColor:[UIColor colorWithRed:(28/255.0) green:(164/255.0) blue:(190/255.0) alpha:1] forState:UIControlStateNormal];
    }

    cell.workout = workout;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NPWorkout *workout = _objects[indexPath.row];
    
    if ([workout.details stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) return 387;
    
    return [workout.details sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(240, 999) lineBreakMode:NSLineBreakByWordWrapping].height + 387;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

#pragma mark - NPWorkoutCell Delegate

- (void)showMapWithWorkout:(NPWorkout *)workout {
    selectedWorkout = workout;
    [self performSegueWithIdentifier:@"ViewMapSegue" sender:self];
}

- (void)showResultsWithWorkout:(NPWorkout *)workout {
    selectedWorkout = workout;
    [self performSegueWithIdentifier:@"ViewResultsSegue" sender:self];
}

- (void)showVerbalsWithWorkout:(NPWorkout *)workout {
    selectedWorkout = workout;
    [self performSegueWithIdentifier:@"ViewVerbalsSegue" sender:self];
}

- (void)submitResultsWithIndexPath:(NSIndexPath *)indexPath {
    selectedWorkout = [_objects objectAtIndex:indexPath.row];
    selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"SubmitResultsSegue" sender:self];
}

#pragma mark - NPResultsSubmit Delegate

- (void)resultsSaved
{
    [[(NPWorkoutCell *)[self.tableView cellForRowAtIndexPath:selectedIndexPath] resultsButton] setTitleColor:[UIColor colorWithRed:(28/255.0) green:(164/255.0) blue:(190/255.0) alpha:1] forState:UIControlStateNormal];
    
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
        AFJSONRequestOperation *op = (AFJSONRequestOperation *)operation;
        NSLog(@"Error: %@", [[op responseJSON] valueForKey:@"error"]);
        [[Mixpanel sharedInstance] track:@"workouts request failed" properties:@{@"error": [[op responseJSON] valueForKey:@"error"]}];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SubmitResultsSegue"]) {
        NPSubmitResultsViewController *view = [segue destinationViewController];
        view.workout = selectedWorkout;
        view.delegate = self;
    } else if ([[segue identifier] isEqualToString:@"ViewResultsSegue"]) {
        NPResultsViewController *view = [segue destinationViewController];
        view.workout = selectedWorkout;
    } else if ([[segue identifier] isEqualToString:@"ViewVerbalsSegue"]) {
        NPVerbalViewController *view = [segue destinationViewController];
        view.workout = selectedWorkout;
    } else if ([[segue identifier] isEqualToString:@"ViewMapSegue"]) {
        NPMapViewController *view = [segue destinationViewController];
        view.workout = selectedWorkout;
    } else if ([[segue identifier] isEqualToString:@"LoginViewSegue"]) {
        NPLoginViewController *view = [segue destinationViewController];
        view.delegate = self;
    }
}
@end
