//
//  QuestionViewController.m
//  iOS
//
//  Created by Dave Henke and Ryan Sullivan on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//

#import "QuestionViewController.h"
#import "QuestionSet.h"
#import "InGameMenuViewController.h"
#import "PostGameMenuViewController.h"
#import "CustomButton.h"
#import "PDColoredProgressView.h"

static const float TIME_INTERVAL = 0.01; // Controls how fast the timer counts down
@implementation QuestionViewController

@synthesize questionCountdownLabel;
@synthesize myScoreCountdownLabel;
@synthesize questionTimer;
@synthesize answer1;
@synthesize answer2;
@synthesize answer3;
@synthesize answer4;
@synthesize questionNumberLabel;
@synthesize questionLabel;
@synthesize roundScoreLabel;
@synthesize usernameLabel;
@synthesize inGameMenuViewController;
@synthesize postGameMenuViewController;
@synthesize longPressGR1;
@synthesize longPressGR2;
@synthesize longPressGR3;
@synthesize longPressGR4;


/**
 This is the fist function that is called when we try to load our view.  We have overridden the default
 function to take in the category that the user has requested.
 @param name - name of view .xib file we are loading
 @param bundle - ??? dont know what this is for
 @param category - category that the user wants to play
 @return id of this questionViewControlelr object loaded
 */
- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle category:(NSString *)category{
	questionCategory = category;
	[super initWithNibName:name bundle:bundle];
	return self;
}





/**
 This function is called shortly after initWithNibName is called (after the view finishes loading). 
 We establish a few notifications and then initialize our game.  These notifications are used by the postGame and inGame menu
 since we are no longer in the questionViewController.
 */
- (void)viewDidLoad {	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(releaseTimer) name:@"ReleaseTimer" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endRound) name:@"EndRound" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submitScore) name:@"SubmitScore" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proceedToNextQuestion) name:@"NextQuestion" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeView) name:@"CloseQuestionView" object:nil];
	
	[self initializeLongPress];
	
	//initialize game
	[self initGame];
	
    [super viewDidLoad];
}


/**
 Initializes our LongPressGestureReceivers
 */
- (void) initializeLongPress{
	longPressGR1.minimumPressDuration = 3;
	longPressGR2.minimumPressDuration = 3;
	longPressGR3.minimumPressDuration = 3;
	longPressGR4.minimumPressDuration = 3;
	longPressGR1 = [[UILongPressGestureRecognizer alloc] initWithTarget:[[answer1 allTargets] anyObject] action:@selector(longPressDetected:)];
	longPressGR2 = [[UILongPressGestureRecognizer alloc] initWithTarget:[[answer1 allTargets] anyObject] action:@selector(longPressDetected:)];
	longPressGR3 = [[UILongPressGestureRecognizer alloc] initWithTarget:[[answer1 allTargets] anyObject] action:@selector(longPressDetected:)];
	longPressGR4 = [[UILongPressGestureRecognizer alloc] initWithTarget:[[answer1 allTargets] anyObject] action:@selector(longPressDetected:)];
	[answer1 addGestureRecognizer:longPressGR1];
	[answer2 addGestureRecognizer:longPressGR2];
	[answer3 addGestureRecognizer:longPressGR3];
	[answer4 addGestureRecognizer:longPressGR4];
}


/**
 This function should be called when the user clicks the "Play Game" button
 It loads our QuestionSet object by connecting to the Triviarea server
 and retrieving question information, and then initializes our game interrupt timer
 @param none
 @returns none
 */
- (void)initGame{
	questionCountdown = 1.2;	//this value gives us 12 seconds for our round.  2 to show the question and 10 waiting for an answer.
	currentQuestionNum = 1;		//we want to start on question 1
	roundScore = 0;				
	timerValue = 1000;			//highest score we can receive for a question is 1000
	questionEnded = NO;
	
	//our data.plist file contains information about who the player is logged in as.
	//	this retrieves their username and displays it for them
	NSString *filePath = [self dataFilePath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		NSArray *array = [[NSArray alloc] initWithContentsOfFile:filePath]; 
		usernameLabel.text = [array objectAtIndex:1];
		[array release];
	}
	
	//make our progress bar orange.
	[questionTimer setTintColor: [UIColor orangeColor]];
	
	// fills out QuestionSet object
	ourSet = [[QuestionSet alloc] initWithCategory:questionCategory];
	[self loadQuestion:ourSet andNumber:currentQuestionNum];
	[ourSet.questionArray retain];
	
	
	//initialize our timer interrupt handler
	timer = [NSTimer scheduledTimerWithTimeInterval:TIME_INTERVAL target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
}




/**
	Action that is performed every time the timer goes off.  
 		*Decrement the score (questionCountdown * 1000)
 		*Update progress bar
 		*update score label and position
 */
- (void)timerFired:(NSTimer *)theTimer{
	questionCountdown -= 0.001;
	
	if (questionCountdown > 1.0 && questionCountdown < 1.001) {
		//at 10 seconds, we load our answer buttons with the possible answers
		[self loadAnswerButtons:ourSet andNumber:currentQuestionNum];
	}
	
	//questionCountdown starts at 1.2 (12 seconds).  We dont start subtracting from
	//	the score until 2 seconds have passed.
	if (questionCountdown > 0 && questionCountdown <= 1.0) {
		[self timerFiredRoundInProgress];
	}
	
	//when the timer reaches 0, load the next question and reset the counter
	if (questionCountdown < 0) {
		[self timerFiredRoundOver];
	}
	
	//because we are using floats, the value isnt exactly 1.2
	if (questionCountdown > 1.2 && questionCountdown < 1.201){
		[self timerFiredPostRound];
		[self clearAnswerButtons];
	}
	
	//when we have gone through all 15 questions, end the game
	if (currentQuestionNum > 15) {
		[self endRound];
	}
}


/**
	Whenever the timer fires and our questionCountdown is between 0 and 1.0, we
		want out game to be in progress.  Update score/position
 */
- (void)timerFiredRoundInProgress{
	timerValue = questionCountdown * 1000;
	
	//updates the score label's position to follow the progress bar
	[self updateScorePosition:questionCountdownLabel andPosition:2];
	
	//updates my score label's position to follow the progress bar
	if (answerGiven == FALSE) {
		[self updateScorePosition:myScoreCountdownLabel andPosition:1];
	}
	
	//update progress bar
	questionTimer.progress = questionCountdown;
}


/**
	Whenever the timer fires and our questionCountdown is at 0 we want our round to be over.  
		Prevent score/position from changing, disable buttons, show correct answer, and check
		if the provided answer is correct. 
 */
- (void) timerFiredRoundOver{
	[self questionEnded];
	questionCountdown = 1.5;
}


/**
 Whenever the timer fires and our questionCountdown is at 1.2 (12 seconds) we want to load the next question 
 */
- (void) timerFiredPostRound{
	currentQuestionNum ++;
	[self loadQuestion:ourSet andNumber:currentQuestionNum];
	timerValue = 1000;
	//reset progress bar and score label positions
	questionTimer.progress = 1; 
	[self updateScorePosition:myScoreCountdownLabel andPosition:1];
	[self updateScorePosition:questionCountdownLabel andPosition:2];
}


/**
	Fills our view with the information in our Question object (question text, answer text, etc)
 
 	@param set - QuestionSet object that contains all our question information
 	@param questionNumber - the number of the question we want to display
	@returns none
 */
-(void)loadQuestion:(QuestionSet*)set andNumber:(int) questionNumber{
	//get the question object
	questionToLoad = [set getQuestion:questionNumber];
	
	[self setButtonProperties];

	//display out question's text
	questionLabel.text = questionToLoad.question;
	
	//display question number at top
	questionNumberLabel.text = [NSString stringWithFormat:@"Question %i of %i",questionToLoad.questionNumber, set.maxQuestions];
	
	//update the text of the score label
	roundScoreLabel.text = [NSString stringWithFormat:@"Score: %i",roundScore];
}


/**
 Fills the possible answers with the information in our Question object
 @param - (Question*) set pointer to our question object
 @param - (int) questionNumber
 */
-(void)loadAnswerButtons:(QuestionSet*)set andNumber:(int) questionNumber{
	lastButtonPushed = 0;
	answerGiven = NO;
	questionEnded = NO;
	//Keep track of where we place the correct answer so we know if the user
	//	presses the correct button.  We do not care about the location of
	//	incorrect answers
	int correctIndex = questionToLoad.correctButton;
	NSString* correctAns = questionToLoad.correctAns;
	if (correctIndex == 1) {
		[answer1 setTitle:correctAns forState:UIControlStateNormal];
		[answer2 setTitle:questionToLoad.wrong1 forState:UIControlStateNormal];
		[answer3 setTitle:questionToLoad.wrong2 forState:UIControlStateNormal];
		[answer4 setTitle:questionToLoad.wrong3 forState:UIControlStateNormal];
	} else if (correctIndex == 2) {
		[answer2 setTitle:correctAns forState:UIControlStateNormal];
		[answer1 setTitle:questionToLoad.wrong1 forState:UIControlStateNormal];
		[answer3 setTitle:questionToLoad.wrong2 forState:UIControlStateNormal];
		[answer4 setTitle:questionToLoad.wrong3 forState:UIControlStateNormal];
	} else if (correctIndex == 3) {
		[answer3 setTitle:correctAns forState:UIControlStateNormal];
		[answer2 setTitle:questionToLoad.wrong1 forState:UIControlStateNormal];
		[answer1 setTitle:questionToLoad.wrong2 forState:UIControlStateNormal];
		[answer4 setTitle:questionToLoad.wrong3 forState:UIControlStateNormal];
	} else if (correctIndex == 4) {
		[answer4 setTitle:correctAns forState:UIControlStateNormal];
		[answer2 setTitle:questionToLoad.wrong1 forState:UIControlStateNormal];
		[answer3 setTitle:questionToLoad.wrong2 forState:UIControlStateNormal];
		[answer1 setTitle:questionToLoad.wrong3 forState:UIControlStateNormal];
	}	
}


/**
 When a new question is loaded, we want to show the question immediately but wait
	2 seconds before dislaying possible answers.  This clears the text from the buttons
 */
- (void) clearAnswerButtons{
	[answer1 setTitle:@"" forState:UIControlStateNormal];
	[answer2 setTitle:@"" forState:UIControlStateNormal];
	[answer3 setTitle:@"" forState:UIControlStateNormal];
	[answer4 setTitle:@"" forState:UIControlStateNormal];
	
}


/**
	Helper function that sets our button properties at the beginning of each round.
		Sets word wrapping, alignment, text color, and enables buttons.
 */
-(void)setButtonProperties{
	
	//sets properties of our buttons so that text will be displayed on them properly
	answer1.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    answer1.titleLabel.textAlignment = UITextAlignmentCenter;
	answer1.titleLabel.textColor = [UIColor blueColor];
	answer1.selected = NO;
	[answer1 setEnabled:YES];
    answer2.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    answer2.titleLabel.textAlignment = UITextAlignmentCenter;
	answer2.titleLabel.textColor = [UIColor blueColor];
	answer2.selected = NO;
	[answer2 setEnabled:YES];
    answer3.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    answer3.titleLabel.textAlignment = UITextAlignmentCenter;
	answer3.titleLabel.textColor = [UIColor blueColor];
	answer3.selected = NO;
	[answer3 setEnabled:YES];
    answer4.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    answer4.titleLabel.textAlignment = UITextAlignmentCenter;
	answer4.titleLabel.textColor = [UIColor blueColor];
	answer4.selected = NO;
	[answer4 setEnabled:YES];
	
}


/**
 Whenever the timer fires and our questionCountdown is at 0 want our round to be over.  
 Prevent score/position from changing, disable buttons, show correct answer, and check
 if the provided answer is correct. 
 */
-(void)questionEnded{
	questionEnded = YES;
	
	//for each button, if their state is "selected", set the button to be red (incorrect)
	[answer1 setSelectedImageType:RED];
	[answer2 setSelectedImageType:RED];
	[answer3 setSelectedImageType:RED];
	[answer4 setSelectedImageType:RED];
	
	//if the button is the correct answer, overwrite the buttons red color to be green.
	//	questionToLoad.correctButton contains the index of the correct button;s location
	switch (questionToLoad.correctButton) {
		case 1:
			[answer1 setSelectedImageType:GREEN];
			answer1.selected = YES;
			break;
		case 2:
			[answer2 setSelectedImageType:GREEN];
			answer2.selected = YES;
			break;
		case 3:
			[answer3 setSelectedImageType:GREEN];
			answer3.selected = YES;
			break;
		case 4:
			[answer4 setSelectedImageType:GREEN];
			answer4.selected = YES;
			break;
		default:
			break;
	}
	
	//if they answered correctly
	if (lastButtonPushed == questionToLoad.correctButton) {
		roundScore += (questionScore);
	}	else {
		//update the text of the score label
		[self updateScorePosition:myScoreCountdownLabel andPosition:1];
	}

	//update the text of the score label
	roundScoreLabel.text = [NSString stringWithFormat:@"Score: %i",roundScore];

}


/**
 Event handler for when button 1 is pushed. 
 @param sender - id of the button that called the function
 */
-(void)button1Pushed:(id)sender{
	answerGiven = TRUE;
	if (lastButtonPushed != 1 && questionEnded == NO) {
		lastButtonPushed = 1;
		//answer1.titleLabel.font = [UIFont fontWithName: @"Helvetica" size: 19];
		answer1.selected = YES;
		answer2.selected = NO;
		answer3.selected = NO;
		answer4.selected = NO;
		
		[self updateScorePosition:myScoreCountdownLabel andPosition:1];
		
		questionScore = questionCountdown * 1000;
	}
}


/**
 Event handler for when button 2 is pushed. 
 @param sender - id of the button that called the function
 */
-(void)button2Pushed:(id)sender{
	answerGiven = TRUE;
	
	if(lastButtonPushed != 2 && questionEnded == NO){
		lastButtonPushed = 2;
		answer1.selected = NO;
		answer2.selected = YES;
		answer3.selected = NO;
		answer4.selected = NO;
	
		[self updateScorePosition:myScoreCountdownLabel andPosition:1];
	
		questionScore = questionCountdown * 1000;
	}
}


/**
 Event handler for when button 3 is pushed. 
 @param sender - id of the button that called the function
 */
-(void)button3Pushed:(id)sender{
	answerGiven = TRUE;
	
	if (lastButtonPushed != 3 && questionEnded == NO) {
		lastButtonPushed = 3;
		answer1.selected = NO;
		answer2.selected = NO;
		answer3.selected = YES;
		answer4.selected = NO;
		
		[self updateScorePosition:myScoreCountdownLabel andPosition:1];
		
		questionScore = questionCountdown * 1000;
	}
}


/**
 Event handler for when button 4 is pushed. 
 @param sender - id of the button that called the function
 */
-(void)button4Pushed:(id)sender{
	answerGiven = TRUE;
	
	if (lastButtonPushed != 4 && questionEnded == NO) {
		lastButtonPushed = 4;
		answer1.selected = NO;
		answer2.selected = NO;
		answer3.selected = NO;
		answer4.selected = YES;
		
		[self updateScorePosition:myScoreCountdownLabel andPosition:1];
		
		questionScore = questionCountdown * 1000;
	}
}


/**
	Sets the position and text of the labels that follow our progress bar
	@param - labal - pointer to UILabel that we are updating
	@param - yPos - 1 if we are updating top label, 2 if we are updating 
			bottom label
 */
- (void) updateScorePosition:(UILabel*)label andPosition:(int)yPos{
	//update the text of the score label
	label.text = [NSString stringWithFormat:@"%i",timerValue];
	
	CGPoint myScorePosition;
	myScorePosition.x = (timerValue * 100 / 358) + 20;
	if (yPos == 1) {
		myScorePosition.y = 386;
	}else {
		myScorePosition.y = 417;
	}
	[label setCenter:myScorePosition];
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


/**
 When a round has ended or the user selects from the menu that they wish to end the round, we
 display the most game menu that allows a user to submit score, show leaderboards, or go to the main menu
 */
- (void) endRound{
	self.postGameMenuViewController = [[PostGameMenuViewController alloc] initWithNibName:@"PostGameMenuView" bundle:nil];
	[self.view addSubview:postGameMenuViewController.view];
}


/**
 When the user presses the info button, the in game menu is shown
 */
- (void) infoButtonPressed:(id)sender{
	self.inGameMenuViewController = [[InGameMenuViewController alloc] initWithNibName:@"InGameMenuView" bundle:nil];
	[self.view addSubview:inGameMenuViewController.view];	
}


/**
 When the user wishes to lock in their answer and procees to the next question instead of waiting
 for the remainder of the timer to count down, this function it called.  By setting the questionTimer
 to 0, we fast forward in time but the answer is still submitted.
 */
- (void) proceedToNextQuestion{
	questionCountdown = 0;
	if (lastButtonPushed != questionToLoad.correctButton) {
		timerValue = 0;
		[self updateScorePosition:myScoreCountdownLabel andPosition:1];
	}
}


/**
 Closes our game view and returns to the main menu
 */
- (void) closeView{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveCategoryView" object:self];
	[self.view removeFromSuperview];
}


/**
 After the user has completed a round of questions, they are allowed to submit their score to the leaderboards
 */
- (void) submitScore{
	//retrieve the userID from our stored file
	NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:[self dataFilePath]];
	//sending userID, score, and category to server throgh post request
	NSString *postBody = [NSString stringWithFormat:@"userID=%@&score=%d&category=%@", [array objectAtIndex:0], roundScore, ourSet.category];
	NSString *urlStr = @"http://triviarea.projects.cs.illinois.edu/sendScore.php";  
	NSMutableURLRequest *request;
	NSData *postData = [postBody dataUsingEncoding:NSASCIIStringEncoding];
	NSError *error;
	NSURLResponse *response;
	NSData *dataReply;
	id stringReply;
	
	//format and package our request
	request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:urlStr]];
	[request setHTTPMethod: @"POST"];
	[request setHTTPBody:postData];
	[request setValue:[NSString stringWithFormat:@"%d", [postBody length]] forHTTPHeaderField:@"Content-length"];
	
	//send our request, retrieve our reply
	dataReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	stringReply = (NSString *)[[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
	NSLog(@"Reply: %@", stringReply);
	//there is no reply so assume that score was send properly
}


/**
 This is our long press gesture regocnizer event handler.  When a long press is detected, 
	this function is called.  We take the point where the gesture was received and we match
	what button was pressed.  
 @param sender - (UILongPressGestureRecognizer*) where gesture was received
 */
- (void)longPressDetected:(UILongPressGestureRecognizer*)sender{
	if (sender.state == UIGestureRecognizerStateEnded) {
        //event triggered again when LongPress ends.  This event is caught here.
		//do nothing with it.
    }
    else {
		CGPoint point = [sender locationInView:self.view];
		float xTagFloat = point.x;
		float yTagFloat = point.y;
		int xVal = (int)xTagFloat;
		int yVal = (int)yTagFloat;
		//gesture detected at button1
		if (xVal >= 21 && xVal <=152 && yVal >= 202 && yVal <= 278){
			[[NSNotificationCenter defaultCenter] postNotificationName:@"NextQuestion" object:self];
			
		//gesture detected at button2
		}else if (xVal >= 168 && xVal <=298 && yVal >= 202 && yVal <= 278){
			[[NSNotificationCenter defaultCenter] postNotificationName:@"NextQuestion" object:self];
			
		//gesture detected at button3
		}else if (xVal >= 21 && xVal <=152 && yVal >= 290 && yVal <= 366){
			[[NSNotificationCenter defaultCenter] postNotificationName:@"NextQuestion" object:self];
			
		//gesture detected at button4
		}else if (xVal >= 168 && xVal <=298 && yVal >= 290 && yVal <= 366){
			[[NSNotificationCenter defaultCenter] postNotificationName:@"NextQuestion" object:self];
		}
		
    }
}


- (void)releaseTimer {
	[timer invalidate];
	timer = nil;
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
