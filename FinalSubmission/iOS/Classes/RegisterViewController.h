//
//  RegisterViewController.h
//  iOS
//
//  Created by Ryan Sullivan on 3/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@class RootViewController;

@interface RegisterViewController : UIViewController {
	UITextField* usernameField;
	UITextField* passwordField;
	UITextField* emailField;
	UILabel* errorText;
	User *newUser;
}
													  
@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UITextField *emailField;
@property (nonatomic, retain) IBOutlet UILabel *errorText;
@property (nonatomic, retain) User *newUser;
						
-(void) submit: (id)sender;
-(void) showLogInView: (id)sender;
-(void) showMainMenu: (id)sender;
-(void) setErrorLabel;
-(BOOL) validateRegistration;

						  
													  
@end
