//
//  FriendsLeaderboard.h
//  iOS
//
//  Created by Ryan Sullivan on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Leaderboard.h"

#define kFilename	@"data.plist"

@interface FriendsLeaderboard : NSObject {
	NSString *json;
	Leaderboard *musicLeaderboard;
	Leaderboard *televisionLeaderboard;
	Leaderboard *moviesLeaderboard;
	Leaderboard *historyLeaderboard;
	Leaderboard *sportsLeaderboard;
	Leaderboard *geographyLeaderboard;
	Leaderboard *literatureLeaderboard;
	Leaderboard *scienceLeaderboard;
	Leaderboard *videogamesLeaderboard;
	int numFriends;
}


@property (nonatomic, retain) Leaderboard *musicLeaderboard;
@property (nonatomic, retain) Leaderboard *televisionLeaderboard;
@property (nonatomic, retain) Leaderboard *moviesLeaderboard;
@property (nonatomic, retain) Leaderboard *historyLeaderboard;
@property (nonatomic, retain) Leaderboard *sportsLeaderboard;
@property (nonatomic, retain) Leaderboard *geographyLeaderboard;
@property (nonatomic, retain) Leaderboard *literatureLeaderboard;
@property (nonatomic, retain) Leaderboard *scienceLeaderboard;
@property (nonatomic, retain) Leaderboard *videogamesLeaderboard;
@property (nonatomic) int numFriends;


- (id)init;
- (BOOL)getJSON:(NSString *)category;
- (void)parseAttributes;
- (NSString *)dataFilePath;

@end
