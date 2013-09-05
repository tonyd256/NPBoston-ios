//
//  NPLoginViewController.h
//  NovProject
//
//  Created by Tony DiPasquale on 4/17/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

@class NPUser;

@interface NPLoginViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIButton *fbLoginButton;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong, nonatomic) IBOutlet UITextField *emailText;
@property (strong, nonatomic) IBOutlet UITextField *passText;
@property (strong, nonatomic) IBOutlet UILabel *orLabel;
@property (strong, nonatomic) IBOutlet UIView *loginView;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *signupButton;
@property (strong, nonatomic) IBOutlet UIButton *facebookButton;

@property (strong, nonatomic) IBOutlet UIView *signupView;
@property (strong, nonatomic) IBOutlet UITextField *nameText;
@property (strong, nonatomic) IBOutlet UITextField *emailSignupText;
@property (strong, nonatomic) IBOutlet UITextField *passSignupText;
@property (strong, nonatomic) IBOutlet UITextField *passConfirmText;
@property (strong, nonatomic) IBOutlet UISegmentedControl *genderSelector;
@property (strong, nonatomic) IBOutlet UISegmentedControl *locSelector;
@property (strong, nonatomic) IBOutlet UIButton *signupSubmitButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

- (IBAction)fbLoginButtonAction:(id)sender;
- (IBAction)loginButtonAction:(id)sender;
- (IBAction)signupButtonAction:(id)sender;
- (IBAction)signupSubmitAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end
