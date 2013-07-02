//
//  NPSubmitResultsViewController.m
//  NPBoston
//
//  Created by Tony DiPasquale on 4/29/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPSubmitResultsViewController.h"
#import "ActionSheetPicker.h"
#import "NPAPIClient.h"
#import "SVProgressHUD.h"
#import "Mixpanel.h"
#import "NPUser.h"

@interface NPSubmitResultsViewController ()

@end

@implementation NPSubmitResultsViewController {
    UIPickerView *picker;
    UIActionSheet *sheet;
    UITextView *commentText;
    UITextField *amountText;
    NSArray *workoutTypes;
    NSMutableArray *types;
    NSInteger selectedTypeIndex;
}

@synthesize workout = _workout;

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
    
    [self makeToolBar];
    [self makeAmountTextField];
    [self makeTimePickerView];
    [self makeCommentTextView];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    workoutTypes = [defaults objectForKey:@"types"];
    
    if (!workoutTypes) {
        [SVProgressHUD showWithStatus:@"Loading..."];
        [[Mixpanel sharedInstance] track:@"workout types request attempted"];
        [[NPAPIClient sharedClient] getPath:@"workout_types" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            workoutTypes = [responseObject objectForKey:@"data"];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            types = [[NSMutableArray alloc] init];
            for (id type in workoutTypes) {
                [types addObject:[type valueForKey:@"type"]];
            }
            selectedTypeIndex = [types indexOfObject:self.workout.type];
            
            [defaults setObject:workoutTypes forKey:@"types"];
            [defaults synchronize];
            [[Mixpanel sharedInstance] track:@"workout types request succeeded"];
            [SVProgressHUD dismiss];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [[Mixpanel sharedInstance] track:@"workout types request failed"];
            [SVProgressHUD dismiss];
        }];
    } else {
        types = [[NSMutableArray alloc] init];
        for (id type in workoutTypes) {
            [types addObject:[type valueForKey:@"type"]];
        }
        selectedTypeIndex = [types indexOfObject:self.workout.type];
    }
    
    if (self.workout.result) {
        //fill in stuff
        self.typeCell.detailTextLabel.text = self.workout.result.type;
        self.timeCell.detailTextLabel.text = [NPResult timeToString:self.workout.result.time];
        amountText.text = self.workout.result.amount == 0 ? @"0" : [self.workout.result.amount stringValue];
        self.prCell.detailTextLabel.text = self.workout.result.pr;
        commentText.text = self.workout.result.comment;
    } else {
        self.typeCell.detailTextLabel.text = self.workout.type;
        self.timeCell.detailTextLabel.text = self.workout.time == 0 ? @"00:00:00" : [NPResult timeToString:self.workout.time];
        amountText.text = self.workout.amount == 0 ? @"0" : [self.workout.amount stringValue];
        self.prCell.detailTextLabel.text = @"No";
    }
    
    NSArray *times = [self.timeCell.detailTextLabel.text componentsSeparatedByString:@":"];
    [picker selectRow:[[times objectAtIndex:0] integerValue] inComponent:0 animated:NO];
    [picker selectRow:[[times objectAtIndex:1] integerValue] inComponent:1 animated:NO];
    [picker selectRow:[[times objectAtIndex:2] integerValue] inComponent:2 animated:NO];
    
    [[Mixpanel sharedInstance] track:@"result save view loaded"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)makeToolBar
{
    UIToolbar *bottomBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, 320, 44)];
    [bottomBar setBarStyle:UIBarStyleBlackOpaque];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(submitCancelled:)];
    
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *submitItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(resultSave:)];
    
    [bottomBar setItems:@[cancelItem, flexItem, submitItem]];
    [self.view addSubview:bottomBar];
}

- (void)makeAmountTextField
{
    amountText = [[UITextField alloc] initWithFrame:CGRectMake(93, 12, 210, 19)];
    [amountText setFont:[UIFont boldSystemFontOfSize:15]];
    [amountText setBackgroundColor:[UIColor clearColor]];
    
    UIToolbar *amountBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    amountBar.barStyle = UIBarStyleBlackOpaque;
    [amountBar sizeToFit];
    
    UIBarButtonItem *flexspace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(amountDone:)];
    
    [amountBar setItems:@[flexspace, doneButton]];
    
    [amountText setInputAccessoryView:amountBar];
    [amountText setKeyboardType:UIKeyboardTypeNumberPad];
    
    [self.amountCell addSubview:amountText];
    self.amountCell.detailTextLabel.hidden = YES;
}

- (void)makeTimePickerView
{
    sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [sheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
    [picker setDataSource:self];
    [picker setDelegate:self];
    [picker setShowsSelectionIndicator:YES];
    [sheet addSubview:picker];
    
    UILabel *hl = [[UILabel alloc] initWithFrame:CGRectMake(49, 127, 70, 50)];
    hl.backgroundColor = [UIColor clearColor];
    hl.opaque = NO;
    hl.alpha = 0.5;
    hl.font = [UIFont boldSystemFontOfSize:20];
    hl.text = @"Hrs";
    [sheet addSubview:hl];
    
    UILabel *ml = [[UILabel alloc] initWithFrame:CGRectMake(149, 127, 70, 50)];
    ml.backgroundColor = [UIColor clearColor];
    ml.opaque = NO;
    ml.alpha = 0.5;
    ml.font = [UIFont boldSystemFontOfSize:20];
    ml.text = @"Mins";
    [sheet addSubview:ml];
    
    UILabel *sl = [[UILabel alloc] initWithFrame:CGRectMake(249, 127, 70, 50)];
    sl.backgroundColor = [UIColor clearColor];
    sl.opaque = NO;
    sl.alpha = 0.5;
    sl.font = [UIFont boldSystemFontOfSize:20];
    sl.text = @"Secs";
    [sheet addSubview:sl];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.barStyle = UIBarStyleBlackOpaque;
    [toolbar sizeToFit];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(timePickerCancel:)];
    
    UIBarButtonItem *flexspace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(timePickerDone:)];
    
    [toolbar setItems:@[cancelButton, flexspace, doneButton]];
    
    [sheet addSubview:toolbar];
}

- (void)makeCommentTextView
{
    commentText = [[UITextView alloc] initWithFrame:CGRectMake(95, 4, 210, 90)];
    commentText.editable = YES;
    [commentText setFont:[UIFont systemFontOfSize:14]];
    [commentText setBackgroundColor:[UIColor clearColor]];
    [commentText addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [commentText setDelegate:self];
    
    UIToolbar *commentBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    commentBar.barStyle = UIBarStyleBlackOpaque;
    [commentBar sizeToFit];
    
    UIBarButtonItem *flexspace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(commentDone:)];
    
    [commentBar setItems:@[flexspace, doneButton]];
    
    [commentText setInputAccessoryView:commentBar];
    
    [self.commentCell addSubview:commentText];
    self.commentCell.detailTextLabel.hidden = YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([commentText isFirstResponder] && indexPath.row != 4) {
        [commentText resignFirstResponder];
    } else if ([amountText isFirstResponder] && indexPath.row != 2) {
        [amountText resignFirstResponder];
    }
    
    switch (indexPath.row) {
        case 0:
        {
            //open action view with workout type picker
            ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                self.typeCell.detailTextLabel.text = selectedValue;
                selectedTypeIndex = selectedIndex;
                [self.typeCell.detailTextLabel sizeToFit];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            };
            
            [ActionSheetStringPicker showPickerWithTitle:@"Workout Type" rows:types initialSelection:selectedTypeIndex doneBlock:done cancelBlock:nil origin:tableView];
            
            [[Mixpanel sharedInstance] track:@"result type tapped"];
            break;
        }
            
        case 1:
        {
            //open action view with time picker
            [sheet showInView:self.view];
            [sheet setBounds:CGRectMake(0, 0, 320, 490)];
            [[Mixpanel sharedInstance] track:@"result time tapped"];
            break;
        }
            
        case 2:
        {
            //open dialog to pick amount?
            [amountText becomeFirstResponder];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [[Mixpanel sharedInstance] track:@"result amount tapped"];
            break;
        }
            
        case 3:
            //toggle label to Yes or No
            if ([self.prCell.detailTextLabel.text isEqual:@"No"]) {
                self.prCell.detailTextLabel.text = @"Yes";
            } else {
                self.prCell.detailTextLabel.text = @"No";
            }
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [[Mixpanel sharedInstance] track:@"result pr tapped"];
            break;
            
        case 4:
            //open text edit dialog
            [commentText becomeFirstResponder];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [[Mixpanel sharedInstance] track:@"result comment tapped"];
            break;
            
        default:
            break;
    }
}

- (void)timePickerDone:(id)sender
{
    NSString *time = @"";
    if ([picker selectedRowInComponent:0] < 10) {
        time = [time stringByAppendingString:@"0"];
    }
    time = [time stringByAppendingFormat:@"%d:", [picker selectedRowInComponent:0]];
    
    if ([picker selectedRowInComponent:1] < 10) {
        time = [time stringByAppendingString:@"0"];
    }
    time = [time stringByAppendingFormat:@"%d:", [picker selectedRowInComponent:1]];
    
    if ([picker selectedRowInComponent:2] < 10) {
        time = [time stringByAppendingString:@"0"];
    }
    time = [time stringByAppendingFormat:@"%d", [picker selectedRowInComponent:2]];
    
    self.timeCell.detailTextLabel.text = time;
    [sheet dismissWithClickedButtonIndex:0 animated:YES];
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] animated:YES];
}

- (void)timePickerCancel:(id)sender
{
    [sheet dismissWithClickedButtonIndex:0 animated:YES];
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] animated:YES];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%d", row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return 24;
            
        case 1:
            return 60;
            
        case 2:
            return 60;
            
        default:
            return 60;
    }
}

#define MAX_LENGTH 100
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSUInteger newLength = (textView.text.length - range.length) + text.length;
    if(newLength <= MAX_LENGTH)
    {
        return YES;
    } else {
        NSUInteger emptySpace = MAX_LENGTH - (textView.text.length - range.length);
        textView.text = [[[textView.text substringToIndex:range.location]
                          stringByAppendingString:[text substringToIndex:emptySpace]]
                         stringByAppendingString:[textView.text substringFromIndex:(range.location + range.length)]];
        return NO;
    }
}

- (void)commentDone:(id)sender
{
    [commentText resignFirstResponder];
}

- (void)amountDone:(id)sender
{
    [amountText resignFirstResponder];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *tv = object;
    //Center vertical alignment
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    tv.contentOffset = (CGPoint){.x = 8, .y = -topCorrect};
}

- (void)submitCancelled:(id)sender
{
    //close modal
    [[Mixpanel sharedInstance] track:@"result save cancelled"];
    [commentText removeObserver:self forKeyPath:@"contentSize"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)resultSave:(id)sender
{
    [SVProgressHUD showWithStatus:@"Saving..."];
    [[Mixpanel sharedInstance] track:@"result save attempted"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NPUser *user = [defaults objectForKey:@"user"];
    
    NSDictionary *params = @{@"uid": user.objectId,
                             @"wid": self.workout.objectId,
                             @"type": [[workoutTypes objectAtIndex:selectedTypeIndex] valueForKey:@"_id"],
                             @"time": [NPResult stringToTime:self.timeCell.detailTextLabel.text],
                             @"amount": amountText.text,
                             @"pr": self.prCell.detailTextLabel.text,
                             @"comment": commentText.text};
    
    if (self.workout.result) {
        [[NPAPIClient sharedClient] putPath:[NSString stringWithFormat:@"workouts/%@/results/%@", self.workout.objectId, self.workout.result.objectId] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[Mixpanel sharedInstance] track:@"result save succeeded"];
            
            self.workout.result = [NPResult resultWithObject:[responseObject objectForKey:@"data"]];
            [self.delegate resultsSaved];
            
            [commentText removeObserver:self forKeyPath:@"contentSize"];
            [SVProgressHUD dismiss];
            [self dismissViewControllerAnimated:YES completion:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [SVProgressHUD dismiss];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [[Mixpanel sharedInstance] track:@"result save failed" properties:@{@"error": error.localizedDescription}];
        }];
    } else {
        [[NPAPIClient sharedClient] postPath:[NSString stringWithFormat:@"workouts/%@/results", self.workout.objectId] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[Mixpanel sharedInstance] track:@"result save succeeded"];
            
            self.workout.result = [NPResult resultWithObject:[responseObject objectForKey:@"data"]];
            [self.delegate resultsSaved];
            
            [commentText removeObserver:self forKeyPath:@"contentSize"];
            [SVProgressHUD dismiss];
            [self dismissViewControllerAnimated:YES completion:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [SVProgressHUD dismiss];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [[Mixpanel sharedInstance] track:@"result save failed" properties:@{@"error": error.localizedDescription}];
        }];
    }
}

- (void)viewDidUnload {
    [self setTypeCell:nil];
    [self setTimeCell:nil];
    [self setAmountCell:nil];
    [self setPrCell:nil];
    [self setCommentCell:nil];
    [super viewDidUnload];
}
@end
