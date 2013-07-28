//
//  NPLoginViewController.m
//  NPBoston
//
//  Created by Tony DiPasquale on 4/17/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPLoginViewController.h"
#import "NPAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "Mixpanel.h"
#import "SVProgressHUD.h"
#import "NPAPIClient.h"
#import "NPUser.h"
#import "WCAlertView.h"
#import <MapKit/MapKit.h>

@interface NPLoginViewController () {
    NSString *emailRegEx;
}
@end

@implementation NPLoginViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStateChanged:) name:FBSessionStateChangedNotification object:nil];
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
    
    self.emailText.delegate = self;
    self.emailSignupText.delegate = self;
    self.passText.delegate = self;
    self.passSignupText.delegate = self;
    self.passConfirmText.delegate = self;
    self.nameText.delegate = self;
    
    [[Mixpanel sharedInstance] track:@"login view loaded"];
    
    emailRegEx =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    
    [self.loginView setAlpha:0.0];
}

- (void)viewDidAppear:(BOOL)animated {
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
    // Dispose of any resources that can be recreated.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload {
    [self setFbLoginButton:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setBackgroundImage:nil];
    [super viewDidUnload];
}

- (void)sessionStateChanged:(NSNotification *)notification {
    if (FBSession.activeSession.isOpen) {
        [[Mixpanel sharedInstance] track:@"login succeeded"];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)fbLoginButtonAction:(id)sender {
    NPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [[Mixpanel sharedInstance] track:@"login attempted facebook"];
    [appDelegate openSessionWithAllowLoginUI:YES];
}

- (IBAction)loginButtonAction:(id)sender {
    
    if ([self textFieldIsEmpty:self.emailText]) {
        WCAlertView *alert = [[WCAlertView alloc] initWithTitle:@"Hold On!" message:@"An email is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ([self textFieldIsEmpty:self.passText]) {
        WCAlertView *alert = [[WCAlertView alloc] initWithTitle:@"Hold On!" message:@"A password is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [[Mixpanel sharedInstance] track:@"login attempted"];
    [SVProgressHUD showWithStatus:@"Loging in..."];
    
    [[NPAPIClient sharedClient] postPath:@"users/login" parameters:@{@"email": self.emailText.text,
                                                                    @"pass": self.passText.text}
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NPUser *user = [NPUser userWithObject:[responseObject valueForKey:@"data"]];
       
        [self.delegate userLoggedIn:user];
        
        [[Mixpanel sharedInstance] track:@"login succeeded"];
        [SVProgressHUD dismiss];
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        AFJSONRequestOperation *op = (AFJSONRequestOperation *)operation;
        NSLog(@"Error: %@", [[op responseJSON] valueForKey:@"error"]);
        [[Mixpanel sharedInstance] track:@"login failed" properties:@{@"error": [[op responseJSON] valueForKey:@"error"]}];
        [SVProgressHUD dismiss];
        
        [[[UIAlertView alloc] initWithTitle:@"Error Occured" message:[[op responseJSON] valueForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (IBAction)signupButtonAction:(id)sender {
    //open signup view
    [UIView animateWithDuration:0.6 animations:^{
        CGRect sFrame = self.signupView.frame;
        CGRect lFrame = self.loginView.frame;
        self.loginView.frame = CGRectMake(-320, lFrame.origin.y, lFrame.size.width, lFrame.size.height);
        self.signupView.frame = CGRectMake(0, sFrame.origin.y, sFrame.size.width, sFrame.size.height);
    }];
}

- (IBAction)signupSubmitAction:(id)sender {

    if ([self textFieldIsEmpty:self.nameText]) {
        WCAlertView *alert = [[WCAlertView alloc] initWithTitle:@"Hold On!" message:@"A name is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ([self textFieldIsEmpty:self.emailSignupText]) {
        WCAlertView *alert = [[WCAlertView alloc] initWithTitle:@"Hold On!" message:@"An email is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    } else {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
        if (![pred evaluateWithObject:self.emailSignupText.text]) {
            WCAlertView *alert = [[WCAlertView alloc] initWithTitle:@"Hold On!" message:@"The email is not valid." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    
    if ([self textFieldIsEmpty:self.passSignupText]) {
        WCAlertView *alert = [[WCAlertView alloc] initWithTitle:@"Hold On!" message:@"A password is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ([self textFieldIsEmpty:self.passConfirmText]) {
        WCAlertView *alert = [[WCAlertView alloc] initWithTitle:@"Hold On!" message:@"The confirmation password is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (![self.passConfirmText.text isEqualToString:self.passSignupText.text]) {
        WCAlertView *alert = [[WCAlertView alloc] initWithTitle:@"Hold On!" message:@"The passwords don't match." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [[Mixpanel sharedInstance] track:@"signup attempted"];
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
    
    [[NPAPIClient sharedClient] postPath:@"users" parameters:@{@"email": self.emailSignupText.text,
                                                               @"pass": self.passSignupText.text,
                                                               @"name": self.nameText.text,
                                                               @"location": location,
     @"gender": self.genderSelector.selectedSegmentIndex == 0 ? @"male" : @"female"}
     
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NPUser *user = [NPUser userWithObject:[responseObject valueForKey:@"data"]];
        
        [[NPAPIClient sharedClient] setToken:[[responseObject objectForKey:@"data"] valueForKey:@"token"]];
        [self.delegate userLoggedIn:user];
        
        [[Mixpanel sharedInstance] track:@"signup succeeded"];
        [SVProgressHUD dismiss];
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        AFJSONRequestOperation *op = (AFJSONRequestOperation *)operation;
        NSLog(@"Error: %@", [[op responseJSON] valueForKey:@"error"]);        
        [[Mixpanel sharedInstance] track:@"signup failed" properties:@{@"error": [[op responseJSON] valueForKey:@"error"]}];
        [SVProgressHUD dismiss];
        
        [[[UIAlertView alloc] initWithTitle:@"Error Occured" message:[[op responseJSON] valueForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (IBAction)cancelAction:(id)sender {
    [UIView animateWithDuration:0.6 animations:^{
        CGRect sFrame = self.signupView.frame;
        CGRect lFrame = self.loginView.frame;
        self.loginView.frame = CGRectMake(0, lFrame.origin.y, lFrame.size.width, lFrame.size.height);
        self.signupView.frame = CGRectMake(320, sFrame.origin.y, sFrame.size.width, sFrame.size.height);
    }];
}

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

- (BOOL)textFieldIsEmpty:(UITextField *)textField
{
    return [[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""];
}

@end
