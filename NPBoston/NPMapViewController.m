//
//  NPMapViewController.m
//  NPBoston
//
//  Created by Tony DiPasquale on 4/29/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPMapViewController.h"
#import "Mixpanel.h"
#import "NPAPIClient.h"
#import "SVProgressHUD.h"
#import "NPUser.h"

@interface NPMapViewController ()

@end

@implementation NPMapViewController {
    BOOL editing;
    CLLocationCoordinate2D newCoor;
}

@synthesize lat = _lat;
@synthesize lng = _lng;
@synthesize workoutId = _workoutId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    CLLocationCoordinate2D coor;
    
    if (self.lat) {
        coor.latitude = [self.lat doubleValue];
        coor.longitude = [self.lng doubleValue];
        
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        [point setCoordinate:coor];
        [self.map addAnnotation:point];
    } else {
        coor.latitude = 42.358431;
        coor.longitude = -71.059773;
    }
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = .05;
    span.longitudeDelta = .05;
    region.center = coor;
    region.span = span;
    [self.map setRegion:region];
  
    UITapGestureRecognizer *recog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapTapped:)];
    recog.delegate = self;
    [self.map addGestureRecognizer:recog];
    editing = NO;
    
    [[Mixpanel sharedInstance] track:@"map view loaded"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NPUser *user = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    
    if (user.admin) {
        UIBarButtonItem *setButton = [[UIBarButtonItem alloc] initWithTitle:@"Set" style:UIBarButtonItemStyleBordered target:self action:@selector(setLocationAction:)];
        self.parentViewController.navigationItem.rightBarButtonItem = setButton;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMap:nil];
    [super viewDidUnload];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)setLocationAction:(id)sender
{
    if (editing) {
        [SVProgressHUD showWithStatus:@"Saving..."];
        [[Mixpanel sharedInstance] track:@"workout set location attempted"];
        
        // send request to modify workout        
        [[NPAPIClient sharedClient] putPath:[NSString stringWithFormat:@"workouts/%@/location", self.workoutId] parameters:@{@"lat": [NSNumber numberWithDouble:newCoor.latitude], @"lng": [NSNumber numberWithDouble:newCoor.longitude]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[Mixpanel sharedInstance] track:@"workout set location successful"];
            editing = NO;
            self.parentViewController.navigationItem.rightBarButtonItem.title = @"Set";
            [SVProgressHUD dismiss];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[Mixpanel sharedInstance] track:@"workout set location failed" properties:@{@"error": error.localizedDescription}];
            [SVProgressHUD dismiss];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry an error occured." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
    } else {
        editing = YES;
        self.parentViewController.navigationItem.rightBarButtonItem.title = @"Done";
    }
}

- (void)mapTapped:(UITapGestureRecognizer *)sender
{
    if (!editing) return;
    
    CGPoint point = [sender locationInView:self.map];
    CLLocationCoordinate2D coor = [self.map convertPoint:point toCoordinateFromView:self.map];
    newCoor = coor;
    
    id userLoc = [self.map userLocation];
    NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[self.map annotations]];
    
    if (userLoc != nil) {
        [pins removeObject:userLoc];
    }
    
    [self.map removeAnnotations:pins];
    
    MKPointAnnotation *p = [[MKPointAnnotation alloc] init];
    [p setCoordinate:coor];
    [self.map addAnnotation:p];
}
@end
