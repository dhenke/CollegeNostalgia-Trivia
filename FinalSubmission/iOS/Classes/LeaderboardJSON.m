//
//  LeaderboardJSON.m
//  iOS
//
//  Created by Ryan Sullivan on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LeaderboardJSON.h"
#import "JSON/JSON.h"

@implementation LeaderboardJSON

@synthesize leaderboard;

/**
 Allocates memory for our leaderboard object.
 */
-(id)init{
	if (self = [super init]){
		leaderboard = [[Leaderboard alloc] initLeaders];
	}
	return self;
}


/**
 Makes a post request to the server for the global leaderbaords for a particular category. 
	The retrieved response will be a JSON object.
 @param catagory - NSString containing the category we want
 @return YES if the server responds.
 */
- (BOOL)getJSON:(NSString *)category{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSString *postBody = [NSString stringWithFormat:@"category=%@", category];
	NSString *urlStr = @"http://triviarea.projects.cs.illinois.edu/retrieveLeaderboard.php";  
	NSMutableURLRequest *request;
	NSData *postData = [postBody dataUsingEncoding:NSASCIIStringEncoding];
	NSError *error;
	NSURLResponse *response;
	NSData *dataReply;
	id stringReply;
	
	//make the request
	request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:urlStr]];
	[request setHTTPMethod: @"POST"];
	[request setHTTPBody:postData];
	[request setValue:[NSString stringWithFormat:@"%d", [postBody length]] forHTTPHeaderField:@"Content-length"];
	
	//receive our response
	dataReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	stringReply = (NSString *)[[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
	json = stringReply;	
	
	//do stuff with our reponse
	[self parseAttributes];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	return YES;
}

/**
 Establishes the category and setID in our object from the given JSON string
 @param JSONString - string containing our JSON object
 @returns none
 */
-(void)parseAttributes{
	//give us a fresh leaderboard object
	[leaderboard clearEntries];
	
	//set the category for the leaderboard object
	NSDictionary* JSONObjects = [json JSONValue];
	NSString* category = [JSONObjects objectForKey:@"category"];
	[category retain];
	leaderboard.category = category;
	
	NSString* userKey = [[NSString alloc] init];
	NSString* scoreKey = [[NSString alloc] init];
	NSString* username = [[NSString alloc] init];
	NSString* score = [[NSString alloc] init];
	
	//we can have a max of 100 leaderboard entries.  For each, parse our the userID and score
	for (int x = 1; x < 100; x++) {
		userKey = [NSString stringWithFormat:@"user%d", x];
		scoreKey = [NSString stringWithFormat:@"score%d", x];
		username = [JSONObjects objectForKey:userKey];
		score = [JSONObjects objectForKey:scoreKey];
		if(username != @"" && username != nil){
			[leaderboard addNewEntry:username andScore:score andPlace:x];
		}
	}
	
}

@end
