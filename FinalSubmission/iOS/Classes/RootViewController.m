    //
//  RootViewController.m
//  iOS
//
//  Created by Dave Henke and Ryan Sullivan on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "RegisterViewController.h"
#import "LogInViewController.h"
#import "ForgotPasswordViewController.h"
#import "User.h"

@implementation RootViewController

@synthesize registerViewController;
@synthesize logInViewController;
@synthesize usernameField;
@synthesize passwordField;
@synthesize errorLabel;
@synthesize forgotPasswordViewController;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	errorLabel.text = @"";
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setErrorLabel) name:@"SetErrorLabel" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustView) name:@"AdjustView" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustViewBack) name:@"AdjustViewBack" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];
	
	[self updateCredentials];
	
    [super viewDidLoad];
}



/**
 When the user clicks the Register button, we display the register view
 */
- (void)showRegisterView:(id)sender{
	self.registerViewController = [[RegisterViewController alloc] initWithNibName:@"RegisterView" bundle:nil];
	[self.view addSubview:registerViewController.view];
}


- (void)showForgotPasswordView:(id)sender{
	self.forgotPasswordViewController = [[ForgotPasswordViewController alloc] initWithNibName:@"ForgotPasswordView" bundle:nil];
	[self.view addSubview:forgotPasswordViewController.view];
}

/**
 When the user clicks the Sign in button, we display the log in view
 */
- (void)logIn:(id)sender{
	errorLabel.text = @"";
	newUser = [[User alloc]init];
	newUser.username = usernameField.text;
	newUser.password = passwordField.text;
	[newUser sendLogInRequest];
	
    if ( viewMoved ) {
        NSTimeInterval animationDuration = 0.1;
        CGRect frame = self.view.frame;
        frame.origin.y += 136;
        frame.size.height -= 100;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        self.view.frame = frame;
        [UIView commitAnimations];
        viewMoved = NO;
    }
	
	[self backgroundClick:0];
	
	NSString *filePath = [self dataFilePath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		self.logInViewController = [[LogInViewController alloc] initWithNibName:@"LogInView" bundle:nil];
		[self.view addSubview:logInViewController.view];
	}
}


/**
 This is used when we pull up our keyboard to entry information.  This moves
 the frame up the size of the keyboard so that the text entry box is still in view.
 */
-(void)adjustView{
        NSTimeInterval animationDuration = 0.0;
        CGRect frame = self.view.frame;
        frame.origin.y += 136;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        self.view.frame = frame;
        [UIView commitAnimations];
        viewMoved = NO;
}


/**
 This is used when we hide our keyboard.  This moves the frame down the size of the 
 keyboard so that our origional frame is back in full view.
 */
-(void)adjustViewBack{
		NSTimeInterval animationDuration = 0.0;
		CGRect frame = self.view.frame;
		[UIView beginAnimations:@"ResizeForKeyboard" context:nil];
		[UIView setAnimationDuration:animationDuration];
		self.view.frame = frame;
		[UIView commitAnimations];
		viewMoved = NO;
		[self updateCredentials];
}


/**
 When the user has previously logged in, we want to auto populate the username and password field for
 them for quick log in.
 */
- (void)updateCredentials{
	NSString *filePath = [self dataFilePath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:[self dataFilePath]];
		if ([array count] > 1) {
			usernameField.text = [array objectAtIndex:1];
		}
		if ([array count] > 3){
			passwordField.text = [array objectAtIndex:3];
		}
	}
}

/**
 Displays an error if one occurred
 */
-(void) setErrorLabel{
	errorLabel.text = newUser.errorString;
}


/**
 Returns the path to the file where our user information is stored
 @return string with path to data.plist file
 */
- (NSString *)dataFilePath { 
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *documentsDirectory = [paths objectAtIndex:0]; 
	return [documentsDirectory stringByAppendingPathComponent:kFilename];
}


/**
 Notification handler for when the keyboard is pulled into view.  If the keyboard is already up,
 we do nothing.  If not, we move our view
 */
- (void)keyboardWasShown:(NSNotification *)aNotification {
    if ( keyboardShown )
        return;
	
    if ( ( activeField != usernameField ) && ( activeField != passwordField ) ) {
        NSDictionary *info = [aNotification userInfo];
        NSValue *aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
		
        CGSize keyboardSize = [aValue CGRectValue].size;
		
        NSTimeInterval animationDuration = 0.1;
        CGRect frame = self.view.frame;
        frame.origin.y -= keyboardSize.height-80;
        frame.size.height += keyboardSize.height-44;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        self.view.frame = frame;
        [UIView commitAnimations];
		
        viewMoved = YES;
    }
	
    keyboardShown = YES;
}


/**
 Notification handler for when the keyboard is pulled into view.  If the keyboard is already up,
 we do nothing.  If not, we move our view
 */
- (void)keyboardWasHidden:(NSNotification *)aNotification {
    if ( viewMoved ) {
        NSDictionary *info = [aNotification userInfo];
        NSValue *aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
        CGSize keyboardSize = [aValue CGRectValue].size;
		
        NSTimeInterval animationDuration = 0.1;
        CGRect frame = self.view.frame;
        frame.origin.y += keyboardSize.height-80;
        frame.size.height -= keyboardSize.height-44;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        self.view.frame = frame;
        [UIView commitAnimations];
		
        viewMoved = NO;
    }
	
    keyboardShown = NO;
}


/**
 Notification handler for when the keyboard is pulled into view.  If the keyboard is already up,
 we do nothing.  If not, we move our view
 */
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
}

/**
 Notification handler for when the keyboard is pulled into view.  If the keyboard is already up,
 we do nothing.  If not, we move our view
 */
- (void)textFieldDidEndEditing:(UITextField *)textField {
    activeField = nil;
}


/**
 When the keyboard is up and the background is clicked, we want to hide the keyboard by 
	resigning the first responder
 */
-(IBAction)backgroundClick:(id)sender{
	[usernameField resignFirstResponder];
	[passwordField resignFirstResponder];
}


/**
 When the keyboard is up and the "done" button is clicked, we want to hide the keyboard by 
 resigning the first responder
 */
-(IBAction)doneEditing:(id)sender{
	[sender resignFirstResponder];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[registerViewController release];
    [super dealloc];
}


@end
