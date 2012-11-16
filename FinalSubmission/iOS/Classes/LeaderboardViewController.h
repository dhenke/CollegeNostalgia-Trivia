//
//  LeaderboardViewController.h
//  iOS
//
//  Created by Ryan Sullivan on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeaderboardJSON.h"
#import "FriendsLeaderboard.h"

#define kFilename	@"data.plist"


@interface LeaderboardViewController : UIViewController {
	LeaderboardJSON *leaderboardJSON;
	FriendsLeaderboard *friendsLeaderboard;
	NSString *leaderboardText;
	NSString *category;
	UIButton *categoryButton;
	BOOL showFriends;
	BOOL showGlobal;
}

@property (nonatomic, retain) LeaderboardJSON* leaderboardJSON;
@property (nonatomic, retain) FriendsLeaderboard* friendsLeaderboard;
@property (nonatomic, retain) NSString* category;
@property (nonatomic, retain) IBOutlet UIButton *categoryButton;
@property (nonatomic, retain) IBOutlet UILabel *leaderboardLabel;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;


- (NSString *)buildLeadersString;
- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle category:(NSString *)c;
- (void)changeCategory:(id)sender;
- (void)closeView:(id)sender;
- (void)showGlobal:(id)sender;
- (void)showFriends:(id)sender;
- (NSString *)getFriendsString;
- (NSString *)getCategoryString:(Leaderboard *)categoryLB;
- (NSString *)dataFilePath;


@end
