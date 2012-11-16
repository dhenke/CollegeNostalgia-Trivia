//
//  InGameMenuViewController.m
//  iOS
//
//  Created by Ryan Sullivan on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InGameMenuViewController.h"


@implementation InGameMenuViewController

/**
 Hides the menu from view by removing itself from the Superview
 @param - sender
 */
- (void)resumeGame:(id)sender{
	[self.view removeFromSuperview];
}

/**
 Locks in current score and procedes to next question
 Hides the menu from view by removing itself from the Superview
 @param - sender
 */
- (void)nextQuestion:(id)sender{	
	[self.view removeFromSuperview];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NextQuestion" object:self];
}

/**
 Displays the PostGame menu
 @param - sender
 */
- (void)endRound:(id)sender{
	[self.view removeFromSuperview];	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"EndRound" object:self];
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
