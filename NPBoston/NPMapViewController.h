//
//  NPMapViewController.h
//  NPBoston
//
//  Created by Tony DiPasquale on 4/29/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface NPMapViewController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *map;

@property (strong, nonatomic) NSNumber *lat;
@property (strong, nonatomic) NSNumber *lng;
@property (strong, nonatomic) NSString *workoutId;

@end
