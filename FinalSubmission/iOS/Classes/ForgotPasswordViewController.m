//
//  ForgotPasswordViewController.m
//  iOS
//
//  Created by Dave Henke on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ForgotPasswordViewController.h"


@implementation ForgotPasswordViewController
@synthesize usernameField;
@synthesize emailField;

/**
 When the view loads, make the username field the first responder and adjust the view for the keyboard
 */
- (void)viewDidLoad {
    [super viewDidLoad];
	[usernameField becomeFirstResponder];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AdjustView" object:self];
}

/**
 Function is called when submit is pressed
 @param (id)sender - submit button that was pressed
 */
- (void)submit:(id)sender{
	BOOL sent = [self sendPasswordRequest:usernameField.text andEmail:emailField.text];
	// change the message depending on success
	NSString* message;
	if (sent) {
		message = [NSString stringWithFormat:@"New password will be emailed to you"];
	} else {
		message = [NSString stringWithFormat:@"Unable to reset password. Please check credentials."];
	}
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Forgot Password" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

/**
 Send the password reset POST request. The users password will be reset and emailed to them.
 @param (NSString *)username - the username to reset
 @param (NSString *)email - the email of the user to reset
 @return (BOOL) - YES if reset NO otherwise
 */
-(BOOL) sendPasswordRequest:(NSString*)username andEmail:(NSString*)email{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	
	NSString *postBody = [NSString stringWithFormat:@"request=reset&username=%@&email=%@", username, email];
	//sending username, md5'd password, and email to server through post request
	NSLog(@"Submitting %@", postBody);
	NSString *urlStr = @"http://triviarea.projects.cs.illinois.edu/changePassword.php";  
	NSMutableURLRequest *request;
	NSData *postData = [postBody dataUsingEncoding:NSASCIIStringEncoding];
	NSError *error;
	NSURLResponse *response;
	NSData *dataReply;
	id stringReply;
	
	//format and package our request
	request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:urlStr]];
	[request setHTTPMethod: @"POST"];
	[request setHTTPBody:postData];
	[request setValue:[NSString stringWithFormat:@"%d", [postBody length]] forHTTPHeaderField:@"Content-length"];
	
	//send our request, retrieve our reply
	dataReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	stringReply = (NSString *)[[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
	NSLog(@"Receiving: %@",stringReply);
	// check the response
	if ([stringReply isEqualToString:@"password reset"] == NO) {
		return NO;
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	return YES;
	
}

/**
 Send the password reset POST request. The users password will be reset and emailed to them.
 @param (UIAlertView *)alertView - the alert that was invoked
 @param (NSInteger *)buttonIndex - the button pressed (only one possible)
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AdjustViewBack" object:self];
	[self.view removeFromSuperview];
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
