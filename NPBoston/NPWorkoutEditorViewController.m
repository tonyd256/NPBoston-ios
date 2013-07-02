//
//  NPWorkoutEditorViewController.m
//  NPBoston
//
//  Created by Tony DiPasquale on 5/4/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPWorkoutEditorViewController.h"

@interface NPWorkoutEditorViewController ()

@end

@implementation NPWorkoutEditorViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.titleText isFirstResponder] && indexPath.row != 1) {
        [self.titleText resignFirstResponder];
    } else if ([self.subtitleText isFirstResponder] && indexPath.row != 2) {
        [self.subtitleText resignFirstResponder];
    } else if ([self.urlText isFirstResponder] && indexPath.row != 5) {
        [self.urlText resignFirstResponder];
    }
    
    switch (indexPath.row) {
        case 0:
            // open date picker
            break;
            
        case 1:
            [self.titleText becomeFirstResponder];
            break;
            
        case 2:
            [self.subtitleText becomeFirstResponder];
            break;
            
        case 3:
            // open time picker
            break;
            
        case 4:
            // open location picker
            break;
            
        case 5:
            [self.urlText becomeFirstResponder];
            break;
            
        default:
            break;
    }
}

- (void)viewDidUnload {
    [self setDateCell:nil];
    [self setTypeCell:nil];
    [self setTimeCell:nil];
    [self setLocationCell:nil];
    [self setTitleText:nil];
    [self setSubtitleText:nil];
    [self setUrlText:nil];
    [super viewDidUnload];
}

- (IBAction)cancelAction:(id)sender
{
    
}

- (IBAction)saveAction:(id)sender
{
    
}
@end
