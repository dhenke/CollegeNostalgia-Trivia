//
//  ForgotPasswordViewController.h
//  iOS
//
//  Created by Dave Henke on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ForgotPasswordViewController : UIViewController {
	UITextField* usernameField;
	UITextField* emailField;
}
- (void)submit:(id)sender;
- (BOOL)sendPasswordRequest:(NSString*)username andEmail:(NSString*)email;

@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *emailField;

@end