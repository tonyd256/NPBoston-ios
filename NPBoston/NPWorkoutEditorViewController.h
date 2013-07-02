//
//  NPWorkoutEditorViewController.h
//  NPBoston
//
//  Created by Tony DiPasquale on 5/4/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NPWorkoutEditorViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITableViewCell *dateCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *typeCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *timeCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *locationCell;
@property (strong, nonatomic) IBOutlet UITextField *titleText;
@property (strong, nonatomic) IBOutlet UITextField *subtitleText;
@property (strong, nonatomic) IBOutlet UITextField *urlText;

- (IBAction)cancelAction:(id)sender;
- (IBAction)saveAction:(id)sender;

@end
