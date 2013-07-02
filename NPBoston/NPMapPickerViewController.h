//
//  NPMapPickerViewController.h
//  NPBoston
//
//  Created by Tony DiPasquale on 5/4/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface NPMapPickerViewController : UIViewController

@property (strong, nonatomic) IBOutlet MKMapView *map;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapRecog;

- (IBAction)cancelAction:(id)sender;
- (IBAction)saveAction:(id)sender;

@end
