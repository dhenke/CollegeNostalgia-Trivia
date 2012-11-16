//
//  PostGameMenuViewController.h
//  iOS
//
//  Created by Ryan Sullivan on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectLeaderboardCategoryViewController;

@interface PostGameMenuViewController : UIViewController {
	SelectLeaderboardCategoryViewController *selectLeaderboardViewController;
}

@property (retain, nonatomic) SelectLeaderboardCategoryViewController *selectLeaderboardCategoryViewController;

- (void)mainMenuPushed:(id)sender;
- (void)submitScorePushed:(id)sender;
- (void)showLeaderboardView:(id)sender;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;


@end
