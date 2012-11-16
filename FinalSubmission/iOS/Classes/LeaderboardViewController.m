//
//  LeaderboardViewController.m
//  iOS
//
//  Created by Ryan Sullivan on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LeaderboardViewController.h"
#import "LeaderboardEntry.h"


@implementation LeaderboardViewController

@synthesize leaderboardJSON;
@synthesize friendsLeaderboard;
@synthesize categoryButton;
@synthesize category;
@synthesize leaderboardLabel;
@synthesize scrollView;



/**
 When the leaderboards view is loaded, we want to initialize the category button at the top to the
 current category, and establish a frame that will hold all our leader information.  This frame
 Will contain 1 UILabel that will be only as long as needed.  This frame will be in a UIScrollPane
 so that the user can scroll if there are enough entries.
 @param name - .xib file name
 @param bundle
 @param c - NSString* containing category the user has requested
 */
- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle category:(NSString *)c{
	NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:[self dataFilePath]];
	if ([[array objectAtIndex:2] isEqualToString:@"NO"]) {
		showGlobal = YES;
		showFriends = NO;
	}else {
		showGlobal = NO;
		showFriends = YES;
	}
	
	leaderboardJSON = [[LeaderboardJSON alloc] init];
	friendsLeaderboard = [[FriendsLeaderboard alloc] init];
	leaderboardJSON.leaderboard.category = c;
	category = c;
	[super initWithNibName:name bundle:bundle];
	return self;
}


/**
 When the leaderboards view is loaded, we want to initialize the category button at the top to the
	current category, and establish a frame that will hold all our leader information.  This frame
	Will contain 1 UILabel that will be only as long as needed.  This frame will be in a UIScrollPane
	so that the user can scroll if there are enough entries.
 */
- (void)initialize{
	//set category button at top to display current category
	[categoryButton setTitle:category forState:UIControlStateNormal];
	
	//build our string that contains all our leaderboard information.
	leaderboardText = [self buildLeadersString];
	leaderboardLabel.text = leaderboardText;
	
	//position our leaderboard text in the correct sized frame in a UIScrollPanel
	CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
	CGSize labelSize = [[leaderboardLabel text] sizeWithFont:[leaderboardLabel font] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
	leaderboardLabel.frame = CGRectMake( 0, 0, 280, labelSize.height);
	[scrollView addSubview:leaderboardLabel];
	
	//if the user wants to show the global leaderboards, pull from the leaderboardJSON object
	if (showGlobal) {
		scrollView.contentSize=CGSizeMake(self.view.frame.size.width - 50, [leaderboardJSON.leaderboard.leaders count] * 18);
		
	//the user wants to see a leaderboard of their friends, so pull from friendsLeaderboard object
	}else {
		scrollView.contentSize=CGSizeMake(self.view.frame.size.width - 50, [friendsLeaderboard.musicLeaderboard.leaders count] * 18);
	}
}


/**
 Builds a strings that contains all of our leaderboard information, separated by new lines
 @return NSString* containing our leaderboard text
 */
- (NSString *)buildLeadersString{
	NSString* leaders = [[NSString alloc] initWithString:@""];
	NSString* append = [[NSString alloc] initWithString:@""];
	NSString* spaces = [[NSString alloc] initWithString:@""];
	
	//if we are showing our friends information, we user the friendsLeaderboare object
	if (showFriends) {
		[friendsLeaderboard getJSON:category];
		leaders = [self getFriendsString];
		
	//we are not viewing our friends data, so we use the leaderboardJSON object
	}else {
		[leaderboardJSON getJSON:category];
		leaders = @"";
		for (int x = 0; x < [leaderboardJSON.leaderboard.leaders count]; x++) {
			LeaderboardEntry* curr = [leaderboardJSON.leaderboard.leaders objectAtIndex:x];
			
			if (x <= 10) {
				append = [NSString stringWithFormat:@"%d  %@", curr.place, curr.username];
			}else{
				append = [NSString stringWithFormat:@"%d %@", curr.place, curr.username];
			}
			spaces = @"";
			for (int y = 0; y < (28 - [append length]); y++) {
				spaces = [spaces stringByAppendingFormat:@" "];
			}
			leaders = [leaders stringByAppendingFormat:@"%@%@%d\n", append, spaces, curr.score];
		}
	}
	return leaders;
}
	

/**
 When the user presses the button at the top to change categories, we first close the current leaderboard view.
	We then display the view that allows the user to select a leaderboard category
 */
- (void)changeCategory:(id)sender{
	[self closeView:0];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ShowLeaderboardCategoryView" object:self];
}


/**
 When the user wishes to close the leaderboard view, we must remove the current view and the view that
	allows the user to select the category
 */
- (void)closeView:(id)sender{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveLeaderboardCategoryView" object:self];
	[self.view removeFromSuperview];
}


/**
	Event handler for when the user selects to view the global leaderboards
 */
- (void)showGlobal:(id)sender{
	leaderboardText = @"";
	showGlobal = YES;
	showFriends = NO;
	
	//we must write the current state to a file
	//since when we change categories, we are closing our view, we cannot store the state in a variable.
	NSMutableArray *orig = [[NSMutableArray alloc] initWithContentsOfFile:[self dataFilePath]];
	NSMutableArray *array = [[NSMutableArray alloc] init]; 
	[array addObject:[orig objectAtIndex:0]]; 
	[array addObject:[orig objectAtIndex:1]]; 
	[array addObject:@"NO"];
	[array writeToFile:[self dataFilePath] atomically:YES]; 
	[array release];
	[self initialize];
}


/**
 Event handler for when the user selects to view the friends leaderboards
 */
- (void)showFriends:(id)sender{
	showGlobal = NO;
	showFriends = YES;
	
	//we must write the current state to a file
	//since when we change categories, we are closing our view, we cannot store the state in a variable.
	NSMutableArray *orig = [[NSMutableArray alloc] initWithContentsOfFile:[self dataFilePath]];
	NSMutableArray *array = [[NSMutableArray alloc] init]; 
	[array addObject:[orig objectAtIndex:0]]; 
	[array addObject:[orig objectAtIndex:1]]; 
	[array addObject:@"YES"];
	[array writeToFile:[self dataFilePath] atomically:YES]; 
	[array release];
	[self initialize];
}


/**
 Builds a strings that contains all of our leaderboard information, separated by new lines.
	We must fill the appropriate leaderboard structure based on which category is selected
 @return NSString* containing our leaderboard text
 */
- (NSString *)getFriendsString{
	if ([category isEqualToString:@"Music"]) {
		return [self getCategoryString:friendsLeaderboard.musicLeaderboard];
	}else if ([category isEqualToString:@"Television"]){
		return [self getCategoryString:friendsLeaderboard.televisionLeaderboard];
	}else if ([category isEqualToString:@"Movies"]){
		return [self getCategoryString:friendsLeaderboard.moviesLeaderboard];
	}else if ([category isEqualToString:@"History"]){
		return [self getCategoryString:friendsLeaderboard.historyLeaderboard];
	}else if ([category isEqualToString:@"Sports"]){
		return [self getCategoryString:friendsLeaderboard.sportsLeaderboard];
	}else if ([category isEqualToString:@"Geography"]){
		return [self getCategoryString:friendsLeaderboard.geographyLeaderboard];
	}else if ([category isEqualToString:@"Literature"]){
		return [self getCategoryString:friendsLeaderboard.literatureLeaderboard];
	}else if ([category isEqualToString:@"Science and Technology"]){
		return [self getCategoryString:friendsLeaderboard.scienceLeaderboard];
	}else if ([category isEqualToString:@"Video Games"]){
		return [self getCategoryString:friendsLeaderboard.videogamesLeaderboard];
	}
	return nil;
}


/**
 Builds a strings that contains all of our leaderboard information, separated by new lines.
 We must fill the appropriate leaderboard structure based on which category is selected
 @return NSString* containing our leaderboard text
 */
- (NSString *)getCategoryString:(Leaderboard *)categoryLB{
	NSString* leaders = [[NSString alloc] initWithString:@""];
	NSString* append = [[NSString alloc] initWithString:@""];
	NSString* spaces = [[NSString alloc] initWithString:@""];
	
	//loop through each of our friends and add their scores to our leaderboard list
	for (int x = 0; x < friendsLeaderboard.numFriends; x++) {
		LeaderboardEntry* curr = [categoryLB.leaders objectAtIndex:x];
		
		//formatting difference for double digit entries
		if (x < 9) {
			append = [NSString stringWithFormat:@"%d  %@", curr.place, curr.username];
		}else{
			append = [NSString stringWithFormat:@"%d %@", curr.place, curr.username];
		}
		
		//formatting so that the score is always right aligned in our frame
		spaces = @"";
		for (int y = 0; y < (28 - [append length]); y++) {
			spaces = [spaces stringByAppendingFormat:@" "];
		}
		leaders = [leaders stringByAppendingFormat:@"%@%@%d\n", append, spaces, curr.score];
	}
	return leaders;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeView) name:@"CloseLeaderboardView" object:nil];
	[self initialize];
    [super viewDidLoad];
	
	
}


/**
 Returns the path to the file that contains the information we have scored about our user.
 This file should be located at Documents/data.plist
 @return path to file (NSString *)
 */
- (NSString *)dataFilePath { 
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *documentsDirectory = [paths objectAtIndex:0]; 
	return [documentsDirectory stringByAppendingPathComponent:kFilename];
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
