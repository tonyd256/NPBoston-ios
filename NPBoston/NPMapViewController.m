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
    CLLocationCoordinate2D coor;
}

@synthesize workout = _workout;

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
    
    if (self.workout.lat) {
        coor.latitude = [self.workout.lat doubleValue];
        coor.longitude = [self.workout.lng doubleValue];
        
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
    
    [[Mixpanel sharedInstance] track:@"map view loaded"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

- (IBAction)openAction:(id)sender {
    if ([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] == NSOrderedAscending) {
        NSURL *url = [NSURL URLWithString:@"http://maps.google.com/?q="];
        [[UIApplication sharedApplication] openURL:url];
    } else {
        Class mapItemClass = [MKMapItem class];
        if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
        {
            // Create an MKMapItem to pass to the Maps app
            CLLocationCoordinate2D coordinate = coor;
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                           addressDictionary:nil];
            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
            [mapItem setName:@"Workout"];
            // Pass the map item to the Maps app
            [mapItem openInMapsWithLaunchOptions:nil];
        }
    }
    
}
@end
