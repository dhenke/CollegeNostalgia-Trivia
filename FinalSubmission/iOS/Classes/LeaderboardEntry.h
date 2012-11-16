//
//  LeaderboardEnrty.h
//  iOS
//
//  Created by Ryan Sullivan on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LeaderboardEntry : NSObject {
	int place;
	NSString* username;
	int score;
}

@property (nonatomic) int place;
@property (nonatomic, retain) NSString* username;
@property (nonatomic) int score;

-(id)init;



@end
