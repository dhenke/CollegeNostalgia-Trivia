//
//  LogInViewController.m
//  iOS
//
//  Created by Ryan Sullivan on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LogInViewController.h"
#import "AddFriendsViewController.h"
#import "SelectCategoryViewController.h"
#import "SelectLeaderboardCategoryViewController.h"
#import "ChangePasswordViewController.h"

@implementation LogInViewController

@synthesize usernameText;
@synthesize selectCategoryViewController;
@synthesize selectLeaderboardCategoryViewController;
@synthesize addFriendsViewController;
@synthesize changePasswordViewController;

/**
 When the user clicks the Play button on the main menu, this function displays the category 
 selection view
 */
- (void)showSelectCategoryView:(id)sender{
	self.selectCategoryViewController = [[SelectCategoryViewController alloc] initWithNibName:@"SelectCategoryView" bundle:nil];
	[self.view addSubview:selectCategoryViewController.view];
}


/**
 When the user clicks the Leaderboard button, we display the leaderboard view
 */
- (void)showLeaderboardView:(id)sender{
	self.selectLeaderboardCategoryViewController = [[SelectLeaderboardCategoryViewController alloc] initWithNibName:@"SelectLeaderboardCategoryView" bundle:nil];
	[self.view addSubview:selectLeaderboardCategoryViewController.view];
}


/**
 When the user clicks the Friends button, we display the addFriends view
 */
- (void) showAddFriendsView: (id)sender{
	self.addFriendsViewController = [[AddFriendsViewController alloc] initWithNibName:@"AddFriendsView" bundle:nil];
	[self.view addSubview:addFriendsViewController.view];
}

/**
 When the user clicks the Friends button, we display the addFriends view
 */
- (void) showChangePasswordView: (id)sender{
	self.changePasswordViewController = [[ChangePasswordViewController alloc] initWithNibName:@"ChangePasswordView" bundle:nil];
	[self.view addSubview:changePasswordViewController.view];
}


/**
 When the user clicks the sign out button, we delete the file that contains the users information
 and we then promt them that they successfully logged out.
 */
- (IBAction) signOut: (id)sender{
	NSString *filePath = [self dataFilePath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"Are you sure you wish to sign out?"
							  message:nil
							  delegate:self
							  cancelButtonTitle:@"No"
							  otherButtonTitles:@"Yes", nil];
		[alert show];
		[alert release];
	}
	
}


/**
 Event handler for the alert that confirms that the user wants to log out.  If they select yes,
 then we remove the file.
 @param buttonIndex - index of the button selected. 0=NO, 1=YES
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex == 1) {
		NSString *filePath = [self dataFilePath];
		if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
			NSFileManager *fileManager = [NSFileManager defaultManager];
			[fileManager removeItemAtPath:filePath error:nil];
		}
		[self.view removeFromSuperview];
	}
}


/**
 Returns the path to the file where our user information is stored
 @return string with path to data.plist file
 */
- (NSString *)dataFilePath { 
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *documentsDirectory = [paths objectAtIndex:0]; 
	return [documentsDirectory stringByAppendingPathComponent:kFilename];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLeaderboardView:) name:@"ShowLeaderboardCategoryView" object:nil];
	
	NSString *filePath = [self dataFilePath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:[self dataFilePath]];
		NSString *signedInAs = [NSString stringWithFormat:@"Signed in as: %@", [array objectAtIndex:1]];
		usernameText.text = signedInAs;
	}else {
		[self.view removeFromSuperview];
	}

}



- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
