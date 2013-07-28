//
//  NPWorkoutCell.h
//  NPBoston
//
//  Created by Tony DiPasquale on 4/18/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "NPWorkout.h"

@protocol NPWorkoutCellDelegate <NSObject>

//- (void)showDetailsWithWorkout:(NPWorkout *)workout;
- (void)showVerbalsWithWorkout:(NPWorkout *)workout;
- (void)showMapWithWorkout:(NPWorkout *)workout;
- (void)showResultsWithWorkout:(NPWorkout *)workout;
- (void)submitResultsWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface NPWorkoutCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *verbalButton;
@property (strong, nonatomic) IBOutlet MKMapView *locationMap;
@property (strong, nonatomic) IBOutlet UIButton *resultsButton;
@property (strong, nonatomic) IBOutlet UIView *actionsView;
@property (strong, nonatomic) IBOutlet UIView *cellView;
@property (strong, nonatomic) IBOutlet UIButton *viewResultsButton;
@property (strong, nonatomic) IBOutlet UIButton *viewVerbalsButton;
@property (strong, nonatomic) IBOutlet UILabel *detailsLabel;

@property (strong, nonatomic) NPWorkout *workout;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *userName;
@property (weak, nonatomic) id <NPWorkoutCellDelegate> delegate;

- (IBAction)resultsButtonAction:(UIButton *)sender;
- (IBAction)verbalButtonAction:(UIButton *)sender;
- (IBAction)viewResultsAction:(id)sender;
- (IBAction)viewVerbalsAction:(id)sender;

@end
