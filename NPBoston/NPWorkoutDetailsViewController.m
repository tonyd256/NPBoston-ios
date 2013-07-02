//
//  NPWorkoutDetailsViewController.m
//  NPBoston
//
//  Created by Tony DiPasquale on 4/29/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPWorkoutDetailsViewController.h"
#import "NPMapViewController.h"
#import "NPVerbalViewController.h"
#import "Mixpanel.h"
#import "NPResultsViewController.h"

@interface NPWorkoutDetailsViewController ()

@end

@implementation NPWorkoutDetailsViewController

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
    NPMapViewController *map = [self.viewControllers objectAtIndex:0];
    map.lat = self.workout.lat;
    map.lng = self.workout.lng;
    map.workoutId = self.workout.objectId;
    
    NPVerbalViewController *verbals = [self.viewControllers objectAtIndex:1];
    verbals.workout = self.workout;
    
    NPResultsViewController *results = [self.viewControllers objectAtIndex:2];
    results.workout = self.workout;
    
    [[Mixpanel sharedInstance] track:@"details view loaded"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
