//
//  NPMasterViewController.h
//  NPBoston
//
//  Created by Tony DiPasquale on 4/17/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NPWorkoutCell.h"
#import "NPSubmitResultsViewController.h"
#import "NPLoginViewController.h"

@interface NPMasterViewController : UITableViewController <NPWorkoutCellDelegate, NPResultsSubmitDelegate, NPLoginViewDelegate>

@end
