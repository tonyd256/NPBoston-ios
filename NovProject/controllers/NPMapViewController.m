//
//  NPMapViewController.m
//  NovProject
//
//  Created by Tony DiPasquale on 4/29/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPMapViewController.h"
#import "NPWorkout.h"

@interface NPMapViewController ()

@property (assign, nonatomic) CLLocationCoordinate2D coor;

@end

@implementation NPMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.workout.lat) {
        _coor.latitude = [self.workout.lat doubleValue];
        _coor.longitude = [self.workout.lng doubleValue];
        
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        [point setCoordinate:self.coor];
        [self.map addAnnotation:point];
    } else {
        _coor.latitude = 42.358431;
        _coor.longitude = -71.059773;
    }
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = .05;
    span.longitudeDelta = .05;
    region.center = self.coor;
    region.span = span;
    [self.map setRegion:region];
    [self.map setShowsUserLocation:YES];
    
    [NPAnalytics track:@"map view loaded"];
}

- (void)viewDidUnload
{
    [self setMap:nil];
    [super viewDidUnload];
}

- (IBAction)openAction:(id)sender
{
    if ([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] == NSOrderedAscending) {
        NSURL *url = [NSURL URLWithString:@"http://maps.google.com/?q="];
        [[UIApplication sharedApplication] openURL:url];
    } else {
        Class mapItemClass = [MKMapItem class];
        if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
        {
            // Create an MKMapItem to pass to the Maps app
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.coor addressDictionary:nil];
            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
            [mapItem setName:self.workout.title];
            // Pass the map item to the Maps app
            [mapItem openInMapsWithLaunchOptions:nil];
        }
    }    
}
@end
