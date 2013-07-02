//
//  NPMapPickerViewController.m
//  NPBoston
//
//  Created by Tony DiPasquale on 5/4/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPMapPickerViewController.h"

@interface NPMapPickerViewController ()

@end

@implementation NPMapPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMap:nil];
    [self setTapRecog:nil];
    [super viewDidUnload];
}
- (IBAction)cancelAction:(id)sender {
}

- (IBAction)saveAction:(id)sender {
}
@end
