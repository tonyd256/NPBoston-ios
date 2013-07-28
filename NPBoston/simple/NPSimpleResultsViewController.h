//
//  NPSimpleResultsViewController.h
//  NPBoston
//
//  Created by Tony DiPasquale on 7/23/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NPSubmitResultsViewController.h"
#import "NPLoginViewController.h"

@interface NPSimpleResultsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NPResultsSubmitDelegate, NPLoginViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)recordResultsAction:(id)sender;
- (IBAction)viewDetailsAction:(id)sender;
- (IBAction)giveVerbalAction:(id)sender;

@end
