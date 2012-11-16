//
//  ChangePasswordViewController.m
//  iOS
//
//  Created by Dave Henke on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "User.h"
#define kFilename @"data.plist"
@implementation ChangePasswordViewController

@synthesize newField;
@synthesize currentField;
@synthesize repeatField;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	// load the userID for the password change
	NSString *filePath = [self dataFilePath];
	NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
	userID = [NSString stringWithFormat:@"%@", [array objectAtIndex:0]];
	[userID retain];
	// set the keyboard variables
	[currentField becomeFirstResponder];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AdjustView" object:self];
    [super viewDidLoad];
}

/**
 Closes the current view and moves the keyboard back down into the center of the view
 @param (id)sender - submit button that was pressed
 */
- (void)showLoginView:(id)sender{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AdjustViewBack" object:self];
	[self.view removeFromSuperview];
}

/**
 Function is called when submit is pressed
 @param (id)sender - submit button that was pressed
 */
- (void)submit:(id)sender{
	// make sure both new password fields are the same
	BOOL sent;
	if (![newField.text isEqualToString:repeatField.text]) {
		sent = NO;
	} else {
		// hash the new password
		User* updatedUser = [User alloc];
		updatedUser.password = newField.text;
		[updatedUser getMD5];
		newPass = updatedUser.md5pass;
		[newPass retain];
		[updatedUser release];
		// hash the old password
		updatedUser = [User alloc];
		updatedUser.password = currentField.text;
		[updatedUser getMD5];
		currentPass = updatedUser.md5pass;
		[currentPass retain];
		[updatedUser release];
		sent = [self sendPasswordChangeRequest];
	}
	// change the message depending on success
	NSString* message;
	if (sent) {
		message = [NSString stringWithFormat:@"Password Changed Successfully"];
		NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:[self dataFilePath]];
		// update the file's password field
		[array replaceObjectAtIndex:3 withObject:newField.text];
		// delete the old user file
		NSFileManager *fileManager = [NSFileManager defaultManager];
		[fileManager removeItemAtPath:[self dataFilePath] error:nil];
		// write the new one
		[array writeToFile:[self dataFilePath] atomically:YES]; 
	} else {
		message = [NSString stringWithFormat:@"Unable to change password. Please check credentials."];
	}
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Password" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
	[newPass release];
	[currentPass release];
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
 Send the password change POST request. The users password will be changed to the value in the member variable
 @return (BOOL) - YES if reset NO otherwise
 */
-(BOOL) sendPasswordChangeRequest{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	NSString *postBody = [NSString stringWithFormat:@"request=change&userID=%@&password=%@&newPassword=%@", userID, currentPass, newPass];
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
	if ([stringReply isEqualToString:@"password changed successfully"] == NO) {
		return NO;
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	return YES;
	
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
