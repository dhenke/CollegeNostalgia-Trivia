//
//  FriendsLeaderboard.m
//  iOS
//
//  Created by Ryan Sullivan on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FriendsLeaderboard.h"
#import "JSON/JSON.h"


@implementation FriendsLeaderboard

@synthesize numFriends;
@synthesize musicLeaderboard;
@synthesize televisionLeaderboard;
@synthesize moviesLeaderboard;
@synthesize historyLeaderboard;
@synthesize sportsLeaderboard;
@synthesize geographyLeaderboard;
@synthesize literatureLeaderboard;
@synthesize scienceLeaderboard;
@synthesize videogamesLeaderboard;


/**
 Our friendsLeaderboard object contains a leaderboard object for each category.  
	This function initializes them.
 */
-(id)init{
	if (self = [super init]){
		musicLeaderboard = [[Leaderboard alloc] initLeaders];
		televisionLeaderboard = [[Leaderboard alloc] initLeaders];
		moviesLeaderboard = [[Leaderboard alloc] initLeaders];
		historyLeaderboard = [[Leaderboard alloc] initLeaders];
		sportsLeaderboard = [[Leaderboard alloc] initLeaders];
		geographyLeaderboard = [[Leaderboard alloc] initLeaders];
		literatureLeaderboard = [[Leaderboard alloc] initLeaders];
		scienceLeaderboard = [[Leaderboard alloc] initLeaders];
		videogamesLeaderboard = [[Leaderboard alloc] initLeaders];
	}
	return self;
}

/**
 Makes a post request to the server requesting the friends leaderboards for a given
	userID.
 @param category - string for the category we are requesting.
 @return YES if we successfully retrieve the friends list
 */
- (BOOL)getJSON:(NSString *)category{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
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
	
	//make our request
	request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:urlStr]];
	[request setHTTPMethod: @"POST"];
	[request setHTTPBody:postData];
	[request setValue:[NSString stringWithFormat:@"%d", [postBody length]] forHTTPHeaderField:@"Content-length"];
	
	//receive our response as a JSON
	dataReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	stringReply = (NSString *)[[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
	json = stringReply;	
	
	NSLog(@"%@", stringReply);
	
	//parse our the parts of the JSON we care about
	[self parseAttributes];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	return YES;
}

/**
 Establishes the number of friends and each individual  in our object from the given JSON string
 @param JSONString - string containing our JSON object
 @returns none
 */
-(void)parseAttributes{
	//give us a fresh leaderboard object
	[musicLeaderboard clearEntries];
	[televisionLeaderboard clearEntries];
	[moviesLeaderboard clearEntries];
	[historyLeaderboard clearEntries];
	[sportsLeaderboard clearEntries];
	[geographyLeaderboard clearEntries];
	[literatureLeaderboard clearEntries];
	[scienceLeaderboard clearEntries];
	[videogamesLeaderboard clearEntries];
	//get number of friends
	NSDictionary* JSONObjects = [json JSONValue];
	NSString* num = [JSONObjects objectForKey:@"numFriends"];
	numFriends = [num intValue];
	
	NSString* friendIndex = [[NSString alloc] init];
	NSString* friendName = [[NSString alloc] init];
	
	//loop through each friend object
	for (int x = 0; x < numFriends; x++) {
		friendIndex = [NSString stringWithFormat:@"friend%d", x];
		NSDictionary* friendsObject = [JSONObjects objectForKey:friendIndex];
		
		friendName = [friendsObject objectForKey:@"friendName"];
		
		//add the appropriate information to each leaderboard
		[musicLeaderboard addNewEntry:friendName andScore:[friendsObject objectForKey:@"Music"] andPlace:x+1];
		[televisionLeaderboard addNewEntry:friendName andScore:[friendsObject objectForKey:@"Television"] andPlace:x+1];
		[moviesLeaderboard addNewEntry:friendName andScore:[friendsObject objectForKey:@"Movies"] andPlace:x+1];
		[historyLeaderboard addNewEntry:friendName andScore:[friendsObject objectForKey:@"History"] andPlace:x+1];
		[sportsLeaderboard addNewEntry:friendName andScore:[friendsObject objectForKey:@"Sports"] andPlace:x+1];
		[geographyLeaderboard addNewEntry:friendName andScore:[friendsObject objectForKey:@"Geography"] andPlace:x+1];
		[literatureLeaderboard addNewEntry:friendName andScore:[friendsObject objectForKey:@"Literature"] andPlace:x+1];
		[scienceLeaderboard addNewEntry:friendName andScore:[friendsObject objectForKey:@"Science and Technology"] andPlace:x+1];
		[videogamesLeaderboard addNewEntry:friendName andScore:[friendsObject objectForKey:@"Video Games"] andPlace:x+1];
	}
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

@end
