//
//  NPMapViewController.h
//  NPBoston
//
//  Created by Tony DiPasquale on 4/29/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import <MapKit/MapKit.h>

@class NPWorkout;

@interface NPMapViewController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *map;

@property (strong, nonatomic) NPWorkout *workout;

- (IBAction)openAction:(id)sender;

@end
