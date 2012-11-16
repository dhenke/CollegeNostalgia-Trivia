//
//  ChangePasswordViewController.h
//  iOS
//
//  Created by Dave Henke on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ChangePasswordViewController : UIViewController {
	UITextField* currentField;
	UITextField* newField;
	UITextField* repeatField;
	NSString* userID;
	NSString* newPass;
	NSString* currentPass;
}

@property (nonatomic, retain) IBOutlet UITextField *currentField;
@property (nonatomic, retain) IBOutlet UITextField *newField;
@property (nonatomic, retain) IBOutlet UITextField *repeatField;

- (void)submit:(id)sender;
- (BOOL) sendPasswordChangeRequest;
- (void)showLoginView:(id)sender;
- (NSString *)dataFilePath;
@end
