//
//  SettingsViewController.m
//  iPhoneXMPP
//
//  Created by Eric Chamberlain on 3/18/11.
//  Copyright 2011 RF.com. All rights reserved.
//

#import "SettingsViewController.h"


NSString *const kXMPPmyJID = @"kXMPPmyJID";
NSString *const kXMPPmyPassword = @"kXMPPmyPassword";

@interface SettingsViewController()

@property (strong, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet UILabel *confirmLabel;
@property (strong, nonatomic) IBOutlet UITextField *confirmCodeTextField;

@end

@implementation SettingsViewController

#pragma mark Init/dealloc methods

- (void)awakeFromNib {
  self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [_nextButton addTarget:self action:@selector(registerWithNumberClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(10, -1, 50, 30)];
    [leftView setBackgroundColor:UIColor.clearColor];
    UILabel *codeLabel = [[UILabel alloc] initWithFrame:leftView.frame];
    [codeLabel setBackgroundColor:UIColor.clearColor];
    [codeLabel setText:@"+380"];
    [leftView addSubview:codeLabel];
    [_phoneNumberTextField setLeftView:leftView];
    _phoneNumberTextField.leftViewMode = UITextFieldViewModeAlways;
    _phoneNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    _phoneNumberTextField.layer.cornerRadius = 7.0;
    
    _confirmCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    _confirmCodeTextField.layer.sublayerTransform = CATransform3DMakeTranslation(20, 0, 0);
    _confirmCodeTextField.layer.cornerRadius = 7.0;
}

#pragma mark Private

- (void)setField:(NSString *)field forKey:(NSString *)key
{
  if (field != nil)
  {
    [[NSUserDefaults standardUserDefaults] setObject:field forKey:key];
  } else {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
  }
}

#pragma mark Actions

- (IBAction)registerWithNumberClicked:(id)sender
{
    if (_phoneNumberTextField.text.length != 9) {
        UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Enter valid phone number" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [errorAlert show];
    }
    else
       // [[EBNebo15APIClient sharedClient] registerWithPhoneNumber:[NSString stringWithFormat:@"+380%@",_phoneNumberTextField.text] withCompletion:^(BOOL success){
            [UIView animateWithDuration:0.3 animations:^{
                CGRect buttonFrame = [_nextButton frame];
                buttonFrame.origin.y = 240;
                [_nextButton setFrame:buttonFrame];
            } completion:^(BOOL finished) {
                [_confirmCodeTextField setHidden:NO];
                [_confirmLabel setHidden:NO];
                [_phoneNumberTextField setEnabled:NO];
                [_phoneNumberTextField setAlpha:0.7];
                [_nextButton setTitle:@"Confirm" forState:UIControlStateNormal];
                [_nextButton removeTarget:self action:@selector(registerWithNumberClicked:) forControlEvents:UIControlEventTouchUpInside];
                [_nextButton addTarget:self action:@selector(confirmClicked:) forControlEvents:UIControlEventTouchUpInside];
            }];
       // }];
}

- (IBAction)confirmClicked:(id)sender
{
    if (_phoneNumberTextField.text.length != 9) {
        UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Enter valid phone number" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [errorAlert show];
    }
    else
        [[EBNebo15APIClient sharedClient] confirmRegistrationWithSMSCode:[_confirmCodeTextField text] phoneNumber:[NSString stringWithFormat:@"+380%@",_phoneNumberTextField.text] withCompletion:^(BOOL success) {
            [self setField:[NSString stringWithFormat:@"380%@@xmpp.nebo15.me",_phoneNumberTextField.text] forKey:kXMPPmyJID];
            [self setField:_confirmCodeTextField.text forKey:kXMPPmyPassword];
            
            [self dismissViewControllerAnimated:YES completion:NULL];
        }];
}

@end
