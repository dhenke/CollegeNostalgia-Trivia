//
//  SelectLeaderboardCategoryViewController.m
//  iOS
//
//  Created by Ryan Sullivan on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SelectLeaderboardCategoryViewController.h"


@implementation SelectLeaderboardCategoryViewController


@synthesize listData;
@synthesize leaderboardViewController;
@synthesize receivedData;


/**
 When the user selects a category that they wish to display, they do so by selecting an entry in the tableView.
 We then retrieve the appropriate category based on the index selected and show the QuestionView which
 retrieves a question set and allows the use to play a game
 @param - (UITableView *) pointer the the tableView object
 @param - (NSOndexPath *) pointer to the entry in the tableView that was selected
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row]; 
	//retrieve the category of the selected row
	NSString *rowValue = [listData objectAtIndex:row];
	//show the QuestionView so the user can play a round
	self.leaderboardViewController = [[LeaderboardViewController alloc] initWithNibName:@"LeaderboardView" bundle:nil category:rowValue];
	[self.view addSubview:leaderboardViewController.view];
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
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	//sending userID to server throgh post request
	NSString *postBody = [NSString stringWithFormat:@"userID=0"];
	NSString *urlStr = @"http://triviarea.projects.cs.illinois.edu/retrieveCatNotPlayed.php";  
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
	
	self.listData = [stringReply componentsSeparatedByString:@","];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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

/**
 Removes the selectCategory view
 */
-(void)removeCategoryView{
	[self.view removeFromSuperview];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"AdjustView" object:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeCategoryView) name:@"RemoveLeaderboardCategoryView" object:nil];
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
