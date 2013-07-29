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
#import "NPUser.h"
#import "NPWorkout.h"
#import "NPResult.h"
#import "NPUtils.h"

@interface NPSubmitResultsViewController ()

@property (strong, nonatomic) UIPickerView *picker;
@property (strong, nonatomic) UIActionSheet *sheet;
@property (strong, nonatomic) UITextView *commentText;
@property (strong, nonatomic) UITextField *amountText;
@property (strong, nonatomic) NSArray *workoutTypes;
@property (strong, nonatomic) NSMutableArray *types;
@property (assign, nonatomic) NSInteger selectedTypeIndex;

@end

@implementation NPSubmitResultsViewController

#pragma mark - View flow

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self makeToolBar];
    [self makeAmountTextField];
    [self makeTimePickerView];
    [self makeCommentTextView];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.workoutTypes = [defaults objectForKey:@"types"];
    
    if (!self.workoutTypes) {
        [SVProgressHUD showWithStatus:@"Loading..."];
        [[Mixpanel sharedInstance] track:@"workout types request attempted"];
        [[NPAPIClient sharedClient] getPath:@"workout_types" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.workoutTypes = [responseObject objectForKey:@"data"];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            self.types = [[NSMutableArray alloc] init];
            for (id type in self.workoutTypes) {
                [self.types addObject:[type valueForKey:@"type"]];
            }
            self.selectedTypeIndex = [self.types indexOfObject:self.workout.type];
            
            [defaults setObject:self.workoutTypes forKey:@"types"];
            [defaults synchronize];
            [[Mixpanel sharedInstance] track:@"workout types request succeeded"];
            [SVProgressHUD dismiss];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [NPUtils reportError:error WithMessage:@"workout types request failed" FromOperation:(AFJSONRequestOperation *)operation];
            [SVProgressHUD dismiss];
        }];
    } else {
        self.types = [[NSMutableArray alloc] init];
        for (id type in self.workoutTypes) {
            [self.types addObject:[type valueForKey:@"type"]];
        }
        self.selectedTypeIndex = [self.types indexOfObject:self.workout.type];
    }
    
    if (self.workout.result) {
        //fill in stuff
        self.typeCell.detailTextLabel.text = self.workout.result.type;
        self.timeCell.detailTextLabel.text = [NPUtils timeToString:self.workout.result.time];
        self.amountText.text = self.workout.result.amount == 0 ? @"0" : [self.workout.result.amount stringValue];
        self.prCell.detailTextLabel.text = self.workout.result.pr;
        self.commentText.text = self.workout.result.comment;
    } else {
        self.typeCell.detailTextLabel.text = self.workout.type;
        self.timeCell.detailTextLabel.text = self.workout.time == 0 ? @"00:00:00" : [NPUtils timeToString:self.workout.time];
        self.amountText.text = self.workout.amount == 0 ? @"0" : [self.workout.amount stringValue];
        self.prCell.detailTextLabel.text = @"No";
    }
    
    NSArray *times = [self.timeCell.detailTextLabel.text componentsSeparatedByString:@":"];
    [self.picker selectRow:[[times objectAtIndex:0] integerValue] inComponent:0 animated:NO];
    [self.picker selectRow:[[times objectAtIndex:1] integerValue] inComponent:1 animated:NO];
    [self.picker selectRow:[[times objectAtIndex:2] integerValue] inComponent:2 animated:NO];
    
    [[Mixpanel sharedInstance] track:@"result save view loaded"];
}

- (void)viewDidUnload
{
    [self.commentText removeObserver:self forKeyPath:@"contentSize"];
    [self setTypeCell:nil];
    [self setTimeCell:nil];
    [self setAmountCell:nil];
    [self setPrCell:nil];
    [self setCommentCell:nil];
    [super viewDidUnload];
}

#pragma mark - View controls

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
    self.amountText = [[UITextField alloc] initWithFrame:CGRectMake(93, 12, 210, 19)];
    [self.amountText setFont:[UIFont boldSystemFontOfSize:15]];
    [self.amountText setBackgroundColor:[UIColor clearColor]];
    
    UIToolbar *amountBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    amountBar.barStyle = UIBarStyleBlackOpaque;
    [amountBar sizeToFit];
    
    UIBarButtonItem *flexspace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(amountDone:)];
    
    [amountBar setItems:@[flexspace, doneButton]];
    
    [self.amountText setInputAccessoryView:amountBar];
    [self.amountText setKeyboardType:UIKeyboardTypeNumberPad];
    
    [self.amountCell addSubview:self.amountText];
    self.amountCell.detailTextLabel.hidden = YES;
}

- (void)makeTimePickerView
{
    self.sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [self.sheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    self.picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
    [self.picker setDataSource:self];
    [self.picker setDelegate:self];
    [self.picker setShowsSelectionIndicator:YES];
    [self.sheet addSubview:self.picker];
    
    UILabel *hl = [[UILabel alloc] initWithFrame:CGRectMake(49, 127, 70, 50)];
    hl.backgroundColor = [UIColor clearColor];
    hl.opaque = NO;
    hl.alpha = 0.5;
    hl.font = [UIFont boldSystemFontOfSize:20];
    hl.text = @"Hrs";
    [self.sheet addSubview:hl];
    
    UILabel *ml = [[UILabel alloc] initWithFrame:CGRectMake(149, 127, 70, 50)];
    ml.backgroundColor = [UIColor clearColor];
    ml.opaque = NO;
    ml.alpha = 0.5;
    ml.font = [UIFont boldSystemFontOfSize:20];
    ml.text = @"Mins";
    [self.sheet addSubview:ml];
    
    UILabel *sl = [[UILabel alloc] initWithFrame:CGRectMake(249, 127, 70, 50)];
    sl.backgroundColor = [UIColor clearColor];
    sl.opaque = NO;
    sl.alpha = 0.5;
    sl.font = [UIFont boldSystemFontOfSize:20];
    sl.text = @"Secs";
    [self.sheet addSubview:sl];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.barStyle = UIBarStyleBlackOpaque;
    [toolbar sizeToFit];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(timePickerCancel:)];
    
    UIBarButtonItem *flexspace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(timePickerDone:)];
    
    [toolbar setItems:@[cancelButton, flexspace, doneButton]];
    
    [self.sheet addSubview:toolbar];
}

- (void)makeCommentTextView
{
    self.commentText = [[UITextView alloc] initWithFrame:CGRectMake(95, 4, 210, 90)];
    self.commentText.editable = YES;
    [self.commentText setFont:[UIFont systemFontOfSize:14]];
    [self.commentText setBackgroundColor:[UIColor clearColor]];
    [self.commentText addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [self.commentText setDelegate:self];
    
    UIToolbar *commentBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    commentBar.barStyle = UIBarStyleBlackOpaque;
    [commentBar sizeToFit];
    
    UIBarButtonItem *flexspace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(commentDone:)];
    
    [commentBar setItems:@[flexspace, doneButton]];
    
    [self.commentText setInputAccessoryView:commentBar];
    
    [self.commentCell addSubview:self.commentText];
    self.commentCell.detailTextLabel.hidden = YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.commentText isFirstResponder] && indexPath.row != 4) {
        [self.commentText resignFirstResponder];
    } else if ([self.amountText isFirstResponder] && indexPath.row != 2) {
        [self.amountText resignFirstResponder];
    }
    
    switch (indexPath.row) {
        case 0:
        {
            //open action view with workout type picker
            ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                self.typeCell.detailTextLabel.text = selectedValue;
                self.selectedTypeIndex = selectedIndex;
                [self.typeCell.detailTextLabel sizeToFit];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            };
            
            [ActionSheetStringPicker showPickerWithTitle:@"Workout Type" rows:self.types initialSelection:self.selectedTypeIndex doneBlock:done cancelBlock:nil origin:tableView];
            
            [[Mixpanel sharedInstance] track:@"result type tapped"];
            break;
        }
            
        case 1:
        {
            //open action view with time picker
            [self.sheet showInView:self.view];
            [self.sheet setBounds:CGRectMake(0, 0, 320, 490)];
            [[Mixpanel sharedInstance] track:@"result time tapped"];
            break;
        }
            
        case 2:
        {
            //open dialog to pick amount?
            [self.amountText becomeFirstResponder];
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
            [self.commentText becomeFirstResponder];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [[Mixpanel sharedInstance] track:@"result comment tapped"];
            break;
            
        default:
            break;
    }
}

#pragma mark - Picker View delegate

- (void)timePickerDone:(id)sender
{
    NSString *time = @"";
    if ([self.picker selectedRowInComponent:0] < 10) {
        time = [time stringByAppendingString:@"0"];
    }
    time = [time stringByAppendingFormat:@"%d:", [self.picker selectedRowInComponent:0]];
    
    if ([self.picker selectedRowInComponent:1] < 10) {
        time = [time stringByAppendingString:@"0"];
    }
    time = [time stringByAppendingFormat:@"%d:", [self.picker selectedRowInComponent:1]];
    
    if ([self.picker selectedRowInComponent:2] < 10) {
        time = [time stringByAppendingString:@"0"];
    }
    time = [time stringByAppendingFormat:@"%d", [self.picker selectedRowInComponent:2]];
    
    self.timeCell.detailTextLabel.text = time;
    [self.sheet dismissWithClickedButtonIndex:0 animated:YES];
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] animated:YES];
}

- (void)timePickerCancel:(id)sender
{
    [self.sheet dismissWithClickedButtonIndex:0 animated:YES];
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

#pragma mark - Text field methods

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
    [self.commentText resignFirstResponder];
}

- (void)amountDone:(id)sender
{
    [self.amountText resignFirstResponder];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    UITextView *tv = object;
    //Center vertical alignment
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    tv.contentOffset = (CGPoint){.x = 8, .y = -topCorrect};
}

#pragma mark - Action methods

- (void)submitCancelled:(id)sender
{
    //close modal
    [[Mixpanel sharedInstance] track:@"result save cancelled"];
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
                             @"type": [[self.workoutTypes objectAtIndex:self.selectedTypeIndex] valueForKey:@"_id"],
                             @"time": [NPUtils stringToTime:self.timeCell.detailTextLabel.text],
                             @"amount": self.amountText.text,
                             @"pr": self.prCell.detailTextLabel.text,
                             @"comment": self.commentText.text};
    
    if (self.workout.result) {
        [[NPAPIClient sharedClient] putPath:[NSString stringWithFormat:@"workouts/%@/results/%@", self.workout.objectId, self.workout.result.objectId] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[Mixpanel sharedInstance] track:@"result save succeeded"];
            
            self.workout.result = [NPResult resultWithObject:[responseObject objectForKey:@"data"]];
            if (self.delegate)
                [self.delegate resultsSaved];
            
            [SVProgressHUD dismiss];
            [self dismissViewControllerAnimated:YES completion:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSString *msg = [NPUtils reportError:error WithMessage:@"result save failed" FromOperation:(AFJSONRequestOperation *)operation];
            
            [SVProgressHUD dismiss];
            [[[UIAlertView alloc] initWithTitle:@"Error!" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    } else {
        [[NPAPIClient sharedClient] postPath:[NSString stringWithFormat:@"workouts/%@/results", self.workout.objectId] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[Mixpanel sharedInstance] track:@"result save succeeded"];
            
            self.workout.result = [NPResult resultWithObject:[responseObject objectForKey:@"data"]];
            if (self.delegate)
                [self.delegate resultsSaved];
            
            [SVProgressHUD dismiss];
            [self dismissViewControllerAnimated:YES completion:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSString *msg = [NPUtils reportError:error WithMessage:@"result save failed" FromOperation:(AFJSONRequestOperation *)operation];
            
            [SVProgressHUD dismiss];
            [[[UIAlertView alloc] initWithTitle:@"Error!" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    }
}
@end
