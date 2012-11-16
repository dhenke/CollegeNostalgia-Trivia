//
//  QuestionViewController.h
//  iOS
//
//  Created by Dave Henke and Ryan Sullivan on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QuestionSet;
@class Question;
@class InGameMenuViewController;
@class PostGameMenuViewController;
@class CustomButton;
@class PDColoredProgressView;
#define kFilename	@"data.plist"

/**
	This view controller is in charge of the view relating to displaying questions
 		and taking in user input.
 */
@interface QuestionViewController : UIViewController {
	InGameMenuViewController* inGameMenuViewController;
	PostGameMenuViewController* postGameMenuViewController;
	
	QuestionSet* ourSet;	//contains 15 question objects
	Question* questionToLoad;	//question object that is currently being displayed
	int currentQuestionNum;	//between 1 and 15
	
	NSTimer* timer;	
	float questionCountdown;	//couter that is decremented every time the timer fires
	int questionScore;		
	int timerValue;				//questionCountdown shifted so its between 0 and 1000
	PDColoredProgressView *questionTimer; //score countdown bar 
	UILabel* questionCountdownLabel; //score label that follows countdown bar
	UILabel* myScoreCountdownLabel; //another score that follows countdown bar, locks in when answer is given
	
	int roundScore;			//cumulative score for a round of 15 questions (value)
	UILabel* roundScoreLabel;	//cumulative score for a round of 15 questions (label)
	UILabel* usernameLabel;		//displays to the user who they are currently logged in as
	int lastButtonPushed;		//1 thru 4, keeps track of last button selected to prevent user from selecting same answer and
								//		receiving a lower score
	Boolean answerGiven;	//flag for if an answer has been given
	Boolean questionEnded;	//answer for is a question timer has run out
	NSString* questionCategory;
	
	UILongPressGestureRecognizer *longPressGR1;
	UILongPressGestureRecognizer *longPressGR2;
	UILongPressGestureRecognizer *longPressGR3;
	UILongPressGestureRecognizer *longPressGR4;
}

//Assign outlets to our interface objects so we can manipulate them
@property (nonatomic, retain) IBOutlet UIProgressView *questionTimer;
@property (nonatomic, retain) IBOutlet UILabel *questionCountdownLabel;
@property (nonatomic, retain) IBOutlet UILabel *myScoreCountdownLabel;
@property (nonatomic, retain) IBOutlet CustomButton *answer1;
@property (nonatomic, retain) IBOutlet CustomButton *answer2;
@property (nonatomic, retain) IBOutlet CustomButton *answer3;
@property (nonatomic, retain) IBOutlet CustomButton *answer4;
@property (nonatomic, retain) IBOutlet UILabel *questionNumberLabel;
@property (nonatomic, retain) IBOutlet UILabel *questionLabel;
@property (nonatomic, retain) IBOutlet UILabel *roundScoreLabel;
@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) InGameMenuViewController *inGameMenuViewController;
@property (nonatomic, retain) PostGameMenuViewController *postGameMenuViewController;
@property (nonatomic, retain) UILongPressGestureRecognizer *longPressGR1;
@property (nonatomic, retain) UILongPressGestureRecognizer *longPressGR2;
@property (nonatomic, retain) UILongPressGestureRecognizer *longPressGR3;
@property (nonatomic, retain) UILongPressGestureRecognizer *longPressGR4;

/* Function declarations */
- (void) timerFired:(NSTimer *)theTimer;
- (void) initGame;
- (void) initializeLongPress;
- (void) loadQuestion:(QuestionSet*)set andNumber:(int) questionNumber;
- (void) loadAnswerButtons:(QuestionSet*)set andNumber:(int) questionNumber;
- (void) clearAnswerButtons;
- (void) setButtonProperties;
- (void) timerFiredRoundInProgress;
- (void) timerFiredRoundOver;
- (void) timerFiredPostRound;
- (void) questionEnded;
- (void) updateScorePosition:(UILabel*)label andPosition:(int) yPos;
- (void) endRound;
- (void) infoButtonPressed:(id)sender;
- (void) proceedToNextQuestion;
- (void) submitScore;

- (void) button1Pushed: (id)sender;
- (void) button2Pushed: (id)sender;
- (void) button3Pushed: (id)sender;
- (void) button4Pushed: (id)sender;

- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle category:(NSString *)category;
- (NSString *)dataFilePath;
- (void)longPressDetected:(id)sender;


@end
