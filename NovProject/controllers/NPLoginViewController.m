//
//  NPLoginViewController.m
//  NPBoston
//
//  Created by Tony DiPasquale on 4/17/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "NPLoginViewController.h"
#import "NPAppSession.h"
#import "NPAuthenticator.h"
#import "NPFacebookHandler.h"
#import "SVProgressHUD.h"
#import "NPUser.h"
#import "NPUtils.h"
#import "WCAlertView.h"
#import "NSString+Extensions.h"

@interface NPLoginViewController ()

@property (strong, nonatomic) NSString *emailRegEx;

@end

@implementation NPLoginViewController

#pragma mark - View flow

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeView) name:NPSessionAuthenticationSucceededNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeProgress) name:NPSessionAuthenticationFailedNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    if ([[UIScreen mainScreen] bounds].size.height == 568) {
        [self.backgroundImage setImage:[UIImage imageNamed:@"Default-568h@2x.png"]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(-20)-[background]|" options:0 metrics:nil views:@{@"background": self.backgroundImage}]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[background]|" options:0 metrics:nil views:@{@"background": self.backgroundImage}]];
        [self.backgroundImage setContentMode:UIViewContentModeScaleToFill];
    }

    self.signupButton.layer.cornerRadius = 3.0;
    self.loginButton.layer.cornerRadius = 3.0;
    self.facebookButton.layer.cornerRadius = 3.0;
    self.signupSubmitButton.layer.cornerRadius = 3.0;
    self.cancelButton.layer.cornerRadius = 3.0;

    [[Mixpanel sharedInstance] track:@"login view loaded"];

    self.emailRegEx =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";

    [self.loginView setAlpha:0.0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // first blank animation fixes autolayout problems
    [UIView animateWithDuration:0 animations:nil completion:^(BOOL finished) {
        [UIView animateWithDuration:0 animations:^{
            CGRect lFrame = self.loginView.frame;
            self.loginView.frame = CGRectMake(0, lFrame.origin.y-30, lFrame.size.width, lFrame.size.height);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.4 delay:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.loginView.alpha = 1.0;
                CGRect lFrame = self.loginView.frame;
                self.loginView.frame = CGRectMake(0, lFrame.origin.y+30, lFrame.size.width, lFrame.size.height);
            } completion:^(BOOL finished) {

            }];
        }];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)closeView
{
    [self closeProgress];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)closeProgress
{
    [SVProgressHUD dismiss];
}

#pragma mark - Button actions

- (IBAction)fbLoginButtonAction:(id)sender
{
    [SVProgressHUD showWithStatus:@"Authenticating..."];
    [[Mixpanel sharedInstance] track:@"login attempted facebook"];
    [NPFacebookHandler openFacebookSessionWithAllowLoginUI:YES];
}

- (IBAction)loginButtonAction:(id)sender
{
    if ([self.emailText.text isEmpty]) {
        [[[UIAlertView alloc] initWithTitle:@"Hold On!" message:@"An email is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }

    if ([self.passText.text isEmpty]) {
        [[[UIAlertView alloc] initWithTitle:@"Hold On!" message:@"A password is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }

    [SVProgressHUD showWithStatus:@"Loging in..."];
    [[Mixpanel sharedInstance] track:@"login attempted"];

    [NPAuthenticator authenticateUserWithEmail:self.emailText.text andPassword:self.passText.text];
}

- (IBAction)signupButtonAction:(id)sender
{
    //open signup view
    [UIView animateWithDuration:0.6 animations:^{
        CGRect sFrame = self.signupView.frame;
        CGRect lFrame = self.loginView.frame;
        self.loginView.frame = CGRectMake(-320, lFrame.origin.y, lFrame.size.width, lFrame.size.height);
        self.signupView.frame = CGRectMake(0, sFrame.origin.y, sFrame.size.width, sFrame.size.height);
    }];
}

- (IBAction)signupSubmitAction:(id)sender
{
    if ([self.nameText.text isEmpty]) {
        [[[UIAlertView alloc] initWithTitle:@"Hold On!" message:@"A name is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }

    if ([self.emailSignupText.text isEmpty]) {
        [[[UIAlertView alloc] initWithTitle:@"Hold On!" message:@"An email is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    } else {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", self.emailRegEx];
        if (![pred evaluateWithObject:self.emailSignupText.text]) {
            [[[UIAlertView alloc] initWithTitle:@"Hold On!" message:@"The email is not valid." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
    }

    if ([self.passSignupText.text isEmpty]) {
        [[[UIAlertView alloc] initWithTitle:@"Hold On!" message:@"A password is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }

    if ([self.passConfirmText.text isEmpty]) {
        [[[UIAlertView alloc] initWithTitle:@"Hold On!" message:@"A confirmation password is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }

    if (![self.passConfirmText.text isEqualToString:self.passSignupText.text]) {
        [[[UIAlertView alloc] initWithTitle:@"Hold On!" message:@"The passwords don't match." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }

    [SVProgressHUD showWithStatus:@"Signing up..."];

    NSString *location;
    switch (self.locSelector.selectedSegmentIndex) {
        case 0:
            location = @"BOS";
            break;

        case 1:
            location = @"MSN";
            break;

        case 2:
            location = @"SF";
            break;

        default:
            location = @"BOS";
            break;
    }

[NPAuthenticator createUserWithDictionary:@{@"email": self.emailSignupText.text,
                                            @"pass": self.passSignupText.text,
                                            @"name": self.nameText.text,
                                            @"location": location,
                                            @"gender": self.genderSelector.selectedSegmentIndex == 0 ? @"male" : @"female"}];
}

- (IBAction)cancelAction:(id)sender
{
    [UIView animateWithDuration:0.6 animations:^{
        CGRect sFrame = self.signupView.frame;
        CGRect lFrame = self.loginView.frame;
        self.loginView.frame = CGRectMake(0, lFrame.origin.y, lFrame.size.width, lFrame.size.height);
        self.signupView.frame = CGRectMake(320, sFrame.origin.y, sFrame.size.width, sFrame.size.height);
    }];
}

#pragma mark - Keyboard manipulation

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize size = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.25 animations:^{
        CGRect sFrame = self.signupView.frame;
        CGRect lFrame = self.loginView.frame;

        if ([[UIScreen mainScreen] bounds].size.height == 568) {
            self.loginView.frame = CGRectMake(lFrame.origin.x, lFrame.origin.y - size.height - 50, lFrame.size.width, lFrame.size.height);
            self.signupView.frame = CGRectMake(sFrame.origin.x, sFrame.origin.y - size.height, sFrame.size.width, sFrame.size.height);
        } else {
            self.loginView.frame = CGRectMake(lFrame.origin.x, lFrame.origin.y - size.height, lFrame.size.width, lFrame.size.height);
            self.signupView.frame = CGRectMake(sFrame.origin.x, sFrame.origin.y - size.height + 80, sFrame.size.width, sFrame.size.height);
        }
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect sFrame = self.signupView.frame;
        CGRect lFrame = self.loginView.frame;
        self.loginView.frame = CGRectMake(lFrame.origin.x, 0, lFrame.size.width, lFrame.size.height);
        self.signupView.frame = CGRectMake(sFrame.origin.x, 0, sFrame.size.width, sFrame.size.height);
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
