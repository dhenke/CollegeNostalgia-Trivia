//
//  RemoveFriendViewController.h
//  iOS
//
//  Created by Ryan Sullivan on 4/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kFilename @"data.plist"

@interface RemoveFriendViewController : UIViewController {
	NSArray* listData;
}

@property (retain,nonatomic) NSArray *listData;


- (void)parseResponse:(NSString *)reply;
- (void)closeView:(id)sender;
- (NSString *)dataFilePath;
- (void)removeFriend:(NSString *)username;
- (void)doRemoval:(NSString *)userIDStr;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
