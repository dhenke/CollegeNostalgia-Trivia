//
//  LeaderboardEnrty.m
//  iOS
//
//  Created by Ryan Sullivan on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LeaderboardEntry.h"


@implementation LeaderboardEntry

@synthesize place;
@synthesize username;
@synthesize score;



/**
 Allocates memory for our leaderboard object.
 */
-(id)init{
	if (self = [super init]){
		
	}
	return self;
}

@end
