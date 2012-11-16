//
//  Leaderboard.m
//  iOS
//
//  Created by Ryan Sullivan on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Leaderboard.h"


@implementation Leaderboard

@synthesize category;
@synthesize leaders;


/**
 Initialize the leaders array in our leaderboard object
 */
- (id)initLeaders{
	if (self = [super init]){
		leaders = [[NSMutableArray alloc] initWithObjects:nil];  
	}
	return self;
}


/**
 Add the passed object to our leaders array
 @param (Leaderboard *)object - leaderboard entry we are adding to the leaders array. 
 */
- (void)addEntryByObject:(Leaderboard *)object{
	[leaders addObject:object];
	[self sortLeaders];
}


/**
 Creates a new leaderboard object and adds it to out leaders array
 */
- (void)addNewEntry:(NSString *)username andScore:(NSString *)score andPlace:(int)place{
	LeaderboardEntry *newEntry = [[LeaderboardEntry alloc] init];
	newEntry.username = username;
	newEntry.score = [score intValue];
	newEntry.place = place;
	[leaders addObject:newEntry];
	[self sortLeaders];
}


/**
 removes every object in our leaders array
 */
- (void)clearEntries{
	int count = [leaders count];
	for (int x = 0; x < count; x++) {
		[leaders removeLastObject];
	}	
}


/**
 Sorts our leaderboard object by score, descending
 */
-(void)sortLeaders{
	NSSortDescriptor *scoreSorter = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
	[leaders sortUsingDescriptors:[NSMutableArray arrayWithObject:scoreSorter]];
	LeaderboardEntry *current;
	
	//update ranking number for all entries in our leaderboard table
	for (int x = 0; x < [leaders count]; x++) {
		current = [leaders objectAtIndex:x];
		current.place = x+1;
	}
}




@end
