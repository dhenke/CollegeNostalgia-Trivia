//
//  AddFriendsViewController.m
//  iOS
//
//  Created by Ryan Sullivan on 4/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddFriendsViewController.h"
#import "RemoveFriendViewController.h"


@implementation AddFriendsViewController

@synthesize searchTextField;
@synthesize removeFriendViewController;


/**
 When the user wishes to add a friend, they will enter their username or password in the
	searchTextField and click the add button.  This function then sends a request so
	check if the text is a valid username.  If it is, we send an add request with their userID.
	If the username was not found, we search for them by email.  If that was found, send an
	add request with their returned userID.
 @param sender - pointer to button object with which the request was made.
 */
- (void)addFriend:(id)sender{
	if ([searchTextField.text length] > 1) {
		int uIDusername = -1;
		int uIDemail = -1;
		//ask server if username is valid
		uIDusername = [self searchByUsername];
		if (uIDusername == -1) {
			//ask server if email is vaild
			uIDemail = [self searchByEmail];
		}
		//if username found, send add request
		if ( uIDusername != -1){
			[self sendAddRequest:uIDusername];
		//if email found, send add request
		}else if (uIDemail != -1){
			[self sendAddRequest:uIDemail];
		}else{
			[self showMessage:@"Couldn't find by username or email."];
		}
	}else{
		[self showMessage:@"Couldn't find by username or email."];
	}

}


/**
 When the server has responded with a valid userID, we can then go ahead and add the user.  
	To do this, we send a POST request to friends page with request=add and userID = the users ID
	and friendID = the friend to add's user ID
 @param uID - friend to add's userID
 */
- (void)sendAddRequest:(int)uID{
	NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:[self dataFilePath]];
	NSString *postBody = [NSString stringWithFormat:@"request=add&userID=%@&friendID=%d", [array objectAtIndex:0], uID];
	NSString *urlStr = @"http://triviarea.projects.cs.illinois.edu/friends.php";  
	NSMutableURLRequest *request;
	NSData *postData = [postBody dataUsingEncoding:NSASCIIStringEncoding];
	NSError *error;
	NSURLResponse *response;
	NSData *dataReply;
	id stringReply;
	
	request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:urlStr]];
	
	[request setHTTPMethod: @"POST"];
	[request setHTTPBody:postData];
	[request setValue:[NSString stringWithFormat:@"%d", [postBody length]] forHTTPHeaderField:@"Content-length"];
	
	dataReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	stringReply = (NSString *)[[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
	
	if ([stringReply isEqualToString:@"friend added successfully"]) {
		[self showMessage:@"Friend added successfully"];
	}else if ([stringReply isEqualToString:@"already friends with user"]){
		[self showMessage:@"You are already friends with this user"];	
	}
}


/**
 When the user requests to add someone as a friend, we don't know if they are searching by username or
	email address.  This function asks the server if the provided string is a valid username.  If it is,
	the server responds with their userID.  If not, it responds with -1.
 @return int corresponding to userID if valid username, -1 otherwise
 */
- (int)searchByUsername{
	//sending userName to server throgh post request
	NSString *postBody = [NSString stringWithFormat:@"request=searchUsername&username=%@", searchTextField.text];
	NSString *urlStr = @"http://triviarea.projects.cs.illinois.edu/friends.php";  
	NSMutableURLRequest *request;
	NSData *postData = [postBody dataUsingEncoding:NSASCIIStringEncoding];
	NSError *error;
	NSURLResponse *response;
	NSData *dataReply;
	id stringReply;
	
	request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:urlStr]];
	
	[request setHTTPMethod: @"POST"];
	[request setHTTPBody:postData];
	[request setValue:[NSString stringWithFormat:@"%d", [postBody length]] forHTTPHeaderField:@"Content-length"];
	
	dataReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	stringReply = (NSString *)[[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
	return [stringReply intValue];
}


/**
When the user requests to add someone as a friend, we don't know if they are searching by username or
email address.  This function asks the server if the provided string is a valid email.  If it is,
the server responds with their userID.  If not, it responds with -1.
@return int corresponding to userID if valid email, -1 otherwise
*/
- (int)searchByEmail{
	//sending userName to server throgh post request
	NSString *postBody = [NSString stringWithFormat:@"request=searchEmail&email=%@", searchTextField.text];
	NSString *urlStr = @"http://triviarea.projects.cs.illinois.edu/friends.php";  
	NSMutableURLRequest *request;
	NSData *postData = [postBody dataUsingEncoding:NSASCIIStringEncoding];
	NSError *error;
	NSURLResponse *response;
	NSData *dataReply;
	id stringReply;
	
	request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:urlStr]];
	
	[request setHTTPMethod: @"POST"];
	[request setHTTPBody:postData];
	[request setValue:[NSString stringWithFormat:@"%d", [postBody length]] forHTTPHeaderField:@"Content-length"];
	
	dataReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	stringReply = (NSString *)[[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
	return [stringReply intValue];
}


/**
 Simple helper function for displying an alert message to the user.
 @param message - NSString* of the message we want to display
 */
- (void)showMessage:(NSString*)messageText{
	UIAlertView *alert = [[UIAlertView alloc]			
						  initWithTitle: nil
						  message: [NSString stringWithFormat:@"%@", messageText]
						  delegate: nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
}


/**
 Shows the table view that allows a user to edit their friends
 */
- (void)showRemoveFriendsView:(id)sender{
	self.removeFriendViewController = [[RemoveFriendViewController alloc] initWithNibName:@"RemoveFriendView" bundle:nil];
	[self.view addSubview:removeFriendViewController.view];
}


/**
 Removes the add friends view
 */
- (void)closeView:(id)sender{
	[self.view removeFromSuperview];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AdjustViewBack" object:self];
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
 When the keyboard is up and the user does an action that hides the keyboard, this
	removes the keyboard from view
 */
- (void)hideKeyboard{
	[searchTextField resignFirstResponder];
}


/**
 When the keyboard is not up and the user does an action that shows the keyboard, this
 adds the keyboard to view
 */
- (void)showKeyboard{
	[searchTextField becomeFirstResponder];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard) name:@"HideFriendsKeyboard" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard) name:@"ShowFriendsKeyboard" object:nil];
	[searchTextField becomeFirstResponder];
    [super viewDidLoad];
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
