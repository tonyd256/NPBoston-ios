//
//  NPMasterViewController.h
//  NPBoston
//
//  Created by Tony DiPasquale on 4/17/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPWorkoutCell.h"
#import "NPSubmitResultsViewController.h"
#import "NPLoginViewController.h"

@interface NPMasterViewController : UITableViewController <NPWorkoutCellDelegate, NPResultsSubmitDelegate, NPLoginViewDelegate>

@end