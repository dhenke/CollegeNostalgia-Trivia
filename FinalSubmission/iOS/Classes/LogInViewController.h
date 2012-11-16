//
//  LogInViewController.h
//  iOS
//
//  Created by Ryan Sullivan on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"


@class RootViewController;
@class AddFriendsViewController;
@class SelectCategoryViewController;
@class SelectLeaderboardCategoryViewController;
@class ChangePasswordViewController;

#define kFilename	@"data.plist"

@interface LogInViewController : UIViewController {
	UILabel* usernameText;
	
	SelectCategoryViewController *selectCategoryViewController;
	SelectLeaderboardCategoryViewController *selectLeaderboardViewController;
	AddFriendsViewController *addFriendsViewController;
	ChangePasswordViewController *changePasswordViewController;
}

@property (nonatomic, retain) IBOutlet UILabel *usernameText;
@property (retain, nonatomic) SelectCategoryViewController *selectCategoryViewController;
@property (retain, nonatomic) SelectLeaderboardCategoryViewController *selectLeaderboardCategoryViewController;
@property (retain, nonatomic) AddFriendsViewController *addFriendsViewController;
@property (retain, nonatomic) ChangePasswordViewController *changePasswordViewController;

- (void)showSelectCategoryView:(id)sender;
- (void)showLeaderboardView:(id)sender;
- (void)showAddFriendsView: (id)sender;
- (void) showChangePasswordView: (id)sender;
- (IBAction)signOut: (id)sender;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (NSString *)dataFilePath;



@end
