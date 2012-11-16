//
//  LeaderboardJSON.h
//  iOS
//
//  Created by Ryan Sullivan on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Leaderboard.h"


@interface LeaderboardJSON : NSObject {
	Leaderboard *leaderboard;
	NSString *json;
}

@property (nonatomic, retain) Leaderboard *leaderboard;

- (id)init;
- (BOOL)getJSON:(NSString *)category;
- (void)parseAttributes;

@end
