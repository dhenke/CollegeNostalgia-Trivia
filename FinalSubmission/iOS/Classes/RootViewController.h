//
//  RootViewController.h
//  iOS
//
//  Created by Dave Henke and Ryan Sullivan on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RegisterViewController;
@class LogInViewController;
@class ForgotPasswordViewController;
@class User;

#define kFilename	@"data.plist"

@interface RootViewController : UIViewController {
	RegisterViewController *registerViewController;
	LogInViewController *logInViewController;
	ForgotPasswordViewController *forgotPasswordViewController;
	UITextField *usernameField;
	UITextField *passwordField;
	UILabel *errorLabel;
	User *newUser;
	UITextField *activeField;
	BOOL keyboardShown;
	BOOL viewMoved;
	UILabel *usernameLabel;
	
}

@property (retain, nonatomic) ForgotPasswordViewController *forgotPasswordViewController;
@property (retain, nonatomic) RegisterViewController *registerViewController;
@property (retain, nonatomic) LogInViewController *logInViewController;
@property (retain, nonatomic) IBOutlet UITextField *usernameField;
@property (retain, nonatomic) IBOutlet UITextField *passwordField;
@property (retain, nonatomic) IBOutlet UILabel *errorLabel;


- (IBAction) showRegisterView: (id)sender;
- (IBAction) logIn: (id)sender;
- (void)adjustView;
- (void)adjustViewBack;
- (void)updateCredentials;
- (void)setErrorLabel;
- (NSString *)dataFilePath;
- (void)keyboardWasShown:(NSNotification *)aNotification;
- (void)keyboardWasHidden:(NSNotification *)aNotification;
- (void)textFieldDidBeginEditing:(UITextField *)textField;
- (void)textFieldDidEndEditing:(UITextField *)textField;
- (IBAction)backgroundClick:(id)sender;
- (IBAction)doneEditing:(id)sender;
- (void)showForgotPasswordView:(id)sender;

@end
