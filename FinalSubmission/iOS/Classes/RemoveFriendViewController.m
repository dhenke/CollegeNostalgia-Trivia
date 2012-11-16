//
//  RemoveFriendViewController.m
//  iOS
//
//  Created by Ryan Sullivan on 4/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RemoveFriendViewController.h"


@implementation RemoveFriendViewController

@synthesize listData;


/**
	This function is required to be stubbed out so that rows in out tableView can be marked to be deleted.
	They can by deleted by dragging from left to right in a cell, and them pressing the delete button that appears.
 */
-(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
	
}


/**
 When the user selects to delete an object at the row, we must handle the event of deleting the
 user from both the list and from the server
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	// If row is deleted, remove it from the list.
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		// delete your data item here
		NSUInteger row = [indexPath row];
		NSString *rowValue = [listData objectAtIndex:row];
		[self removeFriend:rowValue];
		
		// Animate the deletion from the table.
		[listData removeObjectAtIndex:row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}



/**
 Retrieves the number of rows in our tableView (aka the number of categories available to the user
 */
#pragma mark - 
#pragma mark Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return [self.listData count];
}

/**
 For each entry in our tableView, set the text to be the name of the category that it represents
 @param (UITableView *)tableView - pointer to our tableView
 @param (NSIndexPath *)indexPath - pointer to the entry in the tableView
 @return (UITableViewCell *) - pointer to an entry in our tableView
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: SimpleTableIdentifier];
	if (cell == nil) { 
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleTableIdentifier] autorelease];
	}
	NSUInteger row = [indexPath row]; 
	//set the text of the entry to the appropriate category name
	cell.textColor = [UIColor whiteColor];
	cell.textLabel.text = [listData objectAtIndex:row]; 
	return cell;
}


/**
 Requests from the server the list of available categories for a particular user.  Remember that a user can
 only play each category once each day.
 */
-(void) sendRequest{	
	//retrieve the userID from our stored file
	NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:[self dataFilePath]];
	//sending userID to server throgh post request
	NSString *postBody = [NSString stringWithFormat:@"request=list&userID=%@", [array objectAtIndex:0]];
	NSString *urlStr = @"http://triviarea.projects.cs.illinois.edu/friends.php";  
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
	
	[self parseResponse:stringReply];
	
}

/**
 Given a JSON object containing all of our friends and their high scores, we want to parse our
 just their username so we can present them in our tableview.
 */
- (void)parseResponse:(NSString *)reply{
	NSDictionary* JSONObjects = [reply JSONValue];
	NSString* num = [JSONObjects objectForKey:@"numFriends"];
	int numFriends = [num intValue];
	
	//if the user has no friends, inform them and hide the view
	if (numFriends == 0) {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle: nil
							  message: [NSString stringWithFormat:@"%@",@"You dont have any friends."]
							  delegate: self
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	NSString* friendIndex = [[NSString alloc] init];
	NSString* friendName = [[NSString alloc] init];
	NSString* friendList = [[NSString alloc] init];
	
	//loop through each friend and add it to our friends list
	for (int x = 0; x < numFriends; x++) {
		friendIndex = [NSString stringWithFormat:@"friend%d", x];
		NSDictionary* friendsObject = [JSONObjects objectForKey:friendIndex];
		
		friendName = [friendsObject objectForKey:@"friendName"];
		friendList = [friendList stringByAppendingFormat:@"%@,", friendName];
	}	
	self.listData = [friendList componentsSeparatedByString:@","];
}

/**
 Event handler for the alert that confirms that the user wants to log out.  If they select yes,
 then we remove the file.
 @param buttonIndex - index of the button selected. 0=NO, 1=YES
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AdjustView" object:self];
		[self.view removeFromSuperview];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ShowFriendsKeyboard" object:self];
}


/**
 When the user selects a friend to delete from the TableView, we must make a request to the server
 remove that friendship.  First, we must retrieve that friends userID.  This is done my sending a 
 POST request with your friends (ex-friends) username
 @param username - string containing the friend (ex-friend)'s username
 */
- (void)removeFriend:(NSString *)username{
	//sending userID to server throgh post request
	NSString *postBody = [NSString stringWithFormat:@"request=searchUsername&username=%@", username];
	NSString *urlStr = @"http://triviarea.projects.cs.illinois.edu/friends.php";  
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
	[self doRemoval:stringReply];
	
}


/**
 When the user selects a friend to delete from the TableView, we must make a request to the server
 remove that friendship.  This is done my sending a POST request with your userID and your friends 
 (ex-friends) userID
 @param userIDStr - string containing the friend (ex-friend)'s userID
 */
- (void)doRemoval:(NSString *)userIDStr{
	//retrieve the userID from our stored file
	NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:[self dataFilePath]];
	//sending userID to server throgh post request
	NSString *postBody = [NSString stringWithFormat:@"request=remove&userID=%@&friendID=%@", [array objectAtIndex:0], userIDStr];
	NSString *urlStr = @"http://triviarea.projects.cs.illinois.edu/friends.php";  
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
}

/**
 Returns the path to the file that contains the information we have scored about our user.
 This file should be located at Documents/data.plist
 @return path to file (NSString *)
 */
- (NSString *)dataFilePath { 
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *documentsDirectory = [paths objectAtIndex:0]; 
	return [documentsDirectory stringByAppendingPathComponent:kFilename];
}


- (void)closeView:(id)sender{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AdjustView" object:self];
	[self.view removeFromSuperview];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ShowFriendsKeyboard" object:self];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AdjustViewBack" object:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HideFriendsKeyboard" object:self];
	[self sendRequest];
	[listData retain];
    [super viewDidLoad];
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
