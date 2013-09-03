//
//  NPMasterViewController.m
//  NPBoston
//
//  Created by Tony DiPasquale on 4/17/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

#import "NPMasterViewController.h"
#import "NPResultsViewController.h"
#import "NPVerbalViewController.h"
#import "NPMapViewController.h"

#import "SVProgressHUD.h"
#import "WCAlertView.h"
#import "LUKeychainAccess.h"

#import "NPWorkout.h"
#import "NPUser.h"

#import "NPAPIClient.h"
#import "NPUtils.h"
#import "NPColors.h"
#import "NPAnalytics.h"
#import "NPAppSession.h"

@interface NPMasterViewController ()

@property (strong, nonatomic) NSArray *workouts;
@property (strong, nonatomic) NPWorkout *selectedWorkout;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation NPMasterViewController

#pragma mark - View flow

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.workouts = [[NSArray alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchWorkouts) name:NPSessionAuthenticationSucceededNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginView) name:NPSessionAuthenticationFailedNotification object:nil];

    [[NPAppSession sharedSession] authenticate];

    [[NPAnalytics sharedAnalytics] trackEvent:@"master view loaded"];
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private methods

- (void)fetchWorkouts
{
    [SVProgressHUD showWithStatus:@"Loading..."];
    [[NPAPIClient sharedClient] fetchWorkoutsForLocation:[NPAppSession sharedSession].user.location withSuccessBlock:^(NSArray *workouts) {
        self.workouts = workouts;
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    }];
}

- (void)showLoginView
{
    [self performSegueWithIdentifier:@"LoginViewSegue" sender:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NPSessionAuthenticationFailedNotification object:nil];
}

#pragma mark - Handle shake motion

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.subtype == UIEventSubtypeMotionShake) {
        [WCAlertView showAlertWithTitle:@"Go Back?" message:@"Would you like to go back to the simpler version?" customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
            if (buttonIndex == 0) {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setBool:NO forKey:@"unlocked"];
                [defaults synchronize];

                [[[UIAlertView alloc] initWithTitle:@"Restart the App!" message:@"Exit the app then double click the home button.  Hold down the app icon and click the red circle." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        } cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.workouts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NPWorkoutCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WorkoutCell"];

    if (!cell.delegate) {
        cell.delegate = self;
    }

    NPWorkout *workout = self.workouts[indexPath.row];
    [cell.titleLabel setText:workout.title];
    [cell.subtitleLabel setText:[workout displayDate]];

    if ([workout.details stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        [cell.detailsLabel setHidden:YES];

        [cell.cellView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(6)-[titleLabel]-(2)-[subtitleLabel]-(216)-[viewVerbalsButton][actionsView(==44)]|" options:0 metrics:nil views:@{@"titleLabel": cell.titleLabel, @"subtitleLabel": cell.subtitleLabel, @"actionsView": cell.actionsView, @"viewVerbalsButton": cell.viewVerbalsButton}]];
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
        [cell.verbalButton setTitleColor:[NPColors NPBlue] forState:UIControlStateNormal];
    }

    if (workout.result) {
        [cell.resultsButton setTitleColor:[NPColors NPBlue] forState:UIControlStateNormal];
    }

    cell.workout = workout;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NPWorkout *workout = self.workouts[indexPath.row];

    if ([workout.details stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) return 387;

    return [workout.details sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(240, 999) lineBreakMode:NSLineBreakByWordWrapping].height + 387;
}

#pragma mark - NPWorkoutCell Delegate

- (void)showMapWithWorkout:(NPWorkout *)workout
{
    self.selectedWorkout = workout;
    [self performSegueWithIdentifier:@"ViewMapSegue" sender:self];
}

- (void)showResultsWithWorkout:(NPWorkout *)workout
{
    self.selectedWorkout = workout;
    [self performSegueWithIdentifier:@"ViewResultsSegue" sender:self];
}

- (void)showVerbalsWithWorkout:(NPWorkout *)workout
{
    self.selectedWorkout = workout;
    [self performSegueWithIdentifier:@"ViewVerbalsSegue" sender:self];
}

- (void)submitResultsWithIndexPath:(NSIndexPath *)indexPath
{
    self.selectedWorkout = self.workouts[indexPath.row];
    self.selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"SubmitResultsSegue" sender:self];
}

#pragma mark - NPResultsSubmit Delegate

- (void)resultsSaved
{
    [[(NPWorkoutCell *)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath] resultsButton] setTitleColor:[NPColors NPBlue] forState:UIControlStateNormal];

    [self fetchWorkouts];
}

#pragma mark - Overridden methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SubmitResultsSegue"]) {
        NPSubmitResultsViewController *view = [segue destinationViewController];
        view.workout = self.selectedWorkout;
        view.delegate = self;
    } else if ([[segue identifier] isEqualToString:@"ViewResultsSegue"]) {
        NPResultsViewController *view = [segue destinationViewController];
        view.workout = self.selectedWorkout;
    } else if ([[segue identifier] isEqualToString:@"ViewVerbalsSegue"]) {
        NPVerbalViewController *view = [segue destinationViewController];
        view.workout = self.selectedWorkout;
    } else if ([[segue identifier] isEqualToString:@"ViewMapSegue"]) {
        NPMapViewController *view = [segue destinationViewController];
        view.workout = self.selectedWorkout;
    }
}

@end
