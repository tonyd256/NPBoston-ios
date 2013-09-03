//
//  NPSimpleResultsViewController.h
//  NPBoston
//
//  Created by Tony DiPasquale on 7/23/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPSubmitResultsViewController.h"

@interface NPSimpleResultsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NPResultsSubmitDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)recordResultsAction:(id)sender;
- (IBAction)viewDetailsAction:(id)sender;
- (IBAction)giveVerbalAction:(id)sender;

@end
