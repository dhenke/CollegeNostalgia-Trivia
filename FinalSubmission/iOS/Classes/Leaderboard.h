//
//  Leaderboard.h
//  iOS
//
//  Created by Ryan Sullivan on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeaderboardEntry.h"


@interface Leaderboard : NSObject {
	NSString* category;
	NSMutableArray* leaders;
	

}

@property (nonatomic, retain) NSString* category;
@property (nonatomic, retain) NSMutableArray* leaders;

- (id)initLeaders;
- (void)addNewEntry:(NSString *)username andScore:(NSString *)score andPlace:(int)place;
- (void)addEntryByObject:(Leaderboard *)object;
- (void)clearEntries;
-(void)sortLeaders;


@end
