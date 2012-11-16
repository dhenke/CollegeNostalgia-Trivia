//
//  SelectLeaderboardCategoryViewController.h
//  iOS
//
//  Created by Ryan Sullivan on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "LeaderboardViewController.h"


@interface SelectLeaderboardCategoryViewController : UIViewController {
	NSArray* listData;
	LeaderboardViewController *leaderboardViewController;

}

@property (retain,nonatomic) NSArray *listData;
@property (retain, nonatomic) LeaderboardViewController *leaderboardViewController;
@property (nonatomic, retain) NSMutableData *receivedData;

- (NSString *)dataFilePath;
-(void) sendRequest;
-(void)removeCategoryView;


@end
