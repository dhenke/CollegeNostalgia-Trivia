//
//  AddFriendsViewController.h
//  iOS
//
//  Created by Ryan Sullivan on 4/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kFilename @"data.plist"

@class RemoveFriendViewController;

@interface AddFriendsViewController : UIViewController {
	RemoveFriendViewController *removeFriendViewController;
	UITextField *searchTextField;
}

@property (nonatomic, retain) RemoveFriendViewController *removeFriendViewController;
@property (nonatomic, retain) IBOutlet UITextField *searchTextField;


- (void)sendAddRequest:(int)uID;
- (void)closeView:(id)sender;
- (void)addFriend:(id)sender;
- (int)searchByUsername;
- (int)searchByEmail;
- (void)showMessage:(NSString*)messageText;
- (IBAction)showRemoveFriendsView:(id)sender;
- (NSString *)dataFilePath;
- (void)hideKeyboard;
- (void)showKeyboard;


@end
