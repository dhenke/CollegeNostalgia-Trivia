//
//  PostGameMenuViewController.m
//  iOS
//
//  Created by Ryan Sullivan on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PostGameMenuViewController.h"
#import "SelectLeaderboardCategoryViewController.h"


@implementation PostGameMenuViewController

@synthesize selectLeaderboardCategoryViewController;

/**
 When the user selects that they wish to view the main menu, we close the menu and question views
 */
- (void)mainMenuPushed:(id)sender{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CloseQuestionView" object:self];	
	[self.view removeFromSuperview];
}


/**
 When the user selects that they wish to send their score, we call submitScore() in the questionViewController.
 We then close the menu and question views
 */
- (void)submitScorePushed:(id)sender{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SubmitScore" object:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CloseQuestionView" object:self];	
	[self.view removeFromSuperview];
}

/**
 When the user clicks the Leaderboard button, we display the leaderboard view
 */
- (void)showLeaderboardView:(id)sender{	
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"Viewing Leaderboard will end your current game. Do you wish to continue?"
							  message:nil
							  delegate:self
							  cancelButtonTitle:@"No"
							  otherButtonTitles:@"Yes", nil];
		[alert show];
		[alert release];
}


/**
 Event handler for the alert that confirms that the user wants to log out.  If they select yes,
 then we remove the file.
 @param buttonIndex - index of the button selected. 0=NO, 1=YES
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex == 1) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CloseQuestionView" object:self];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ShowLeaderboardCategoryView" object:self];
		[self.view removeFromSuperview];
	}
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
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
