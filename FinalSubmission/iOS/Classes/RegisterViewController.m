//
//  RegisterViewController.m
//  iOS
//
//  Created by Ryan Sullivan on 3/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RegisterViewController.h"


@implementation RegisterViewController

@synthesize usernameField;
@synthesize passwordField;
@synthesize emailField;
@synthesize errorText;
@synthesize newUser;


/**
 Event handler for when the user clicks the submit button. First validates paramaters. 
	If valid, then we make our request
 */
-(void) submit: (id)sender{
	errorText.text = @"";
	newUser = [[User alloc]init];
	newUser.username = usernameField.text;
	newUser.password = passwordField.text;
	newUser.email = emailField.text;
	if([self validateRegistration] == YES){
		[newUser sendRegisterRequest];
	}
}

/**
 Validates parameters.  If any are invalid, return NO
 @return YES if valid params, else no
 */
-(BOOL) validateRegistration{
	if ([newUser checkUsername] == NO ) {
		errorText.text = @"Invalid username";
		return NO;
	}else if ([newUser checkPassword] == NO) {
		errorText.text = @"Invalid password";
		return NO;
	}else if ([newUser checkEmail] == NO) {
		errorText.text = @"Invalid email";
		return NO;
	}
	return YES;
}


/**
 closes the Register view
 */
-(void) closeView{
	[self.view removeFromSuperview];
}


/**
 Sets the error label to be visable and the text to be the error determined in the user object.
 */
-(void) setErrorLabel{
	errorText.text = newUser.errorString;
}

/**
 Closes the register view and displays the log in view
 */
-(void)showLogInView: (id)sender{
	[self.view removeFromSuperview];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ShowLogInView" object:self];
}

/**
 Displays the main menu by removing the register view 
 */
-(void) showMainMenu: (id)sender{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AdjustViewBack" object:self];
	[self.view removeFromSuperview];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	errorText.text = @"";
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeView) name:@"CloseRegisterView" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setErrorLabel) name:@"SetErrorLabel" object:nil];
    [super viewDidLoad];
	[usernameField becomeFirstResponder];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AdjustView" object:self];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
