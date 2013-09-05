//
//  NPSubmitResultsViewController.h
//  NovProject
//
//  Created by Tony DiPasquale on 4/29/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

@class NPWorkout;

@protocol NPResultsSubmitDelegate <NSObject>

- (void)resultsSaved;

@end

@interface NPSubmitResultsViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITableViewCell *typeCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *timeCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *amountCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *prCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *commentCell;

@property (strong, nonatomic) NPWorkout *workout;
@property (weak, nonatomic) id <NPResultsSubmitDelegate> delegate;

@end
