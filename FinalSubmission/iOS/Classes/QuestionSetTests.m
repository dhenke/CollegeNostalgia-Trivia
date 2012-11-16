//
//  QuestionSetTests.m
//  iOS
//
//  Created by Ryan Sullivan on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QuestionSetTests.h"


@implementation QuestionSetTests

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

/**
	Set up common variables
 */
-(void) setUp {
	testSet = [[QuestionSet alloc] initWithCategory:@"oldExampleJSON"];
}

/**
	Free memory after each test
	*/
-(void) tearDown {
	[testSet release];
}

/**
	Tests that the application launches
 */
- (void) testAppDelegate {
    id yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(yourApplicationDelegate, @"UIApplication failed to find the AppDelegate");
    
}

/**
	Tests that the QuestionSet object is loaded with the appropriate parameters
 */
 - (void) testQuestionSetInitialized{
	STAssertTrue([testSet.category isEqualToString:@"Math"], @"The category should have been 'Math'" );
	 
}

/**
	Tests that the test JSON string is loaded, and the first Question object is loaded properly
 */
- (void) testQuestion1Initialized{
	Question* q1 = [testSet getQuestion:1];
	STAssertTrue([q1.question isEqualToString:@"What is a prime number?"], @"unexpected value" );
	STAssertTrue([q1.correctAns isEqualToString:@"2"], @"unexpected value" );
	STAssertTrue([q1.wrong1 isEqualToString:@"4"], @"unexpected value" );
	STAssertTrue([q1.wrong2 isEqualToString:@"6"], @"unexpected value" );
	STAssertTrue([q1.wrong3 isEqualToString:@"8"], @"unexpected value" );
}

/**
	Tests that we can catch when an invalid JSON string is provided
 */
- (void) testInvalidJSON{
	NSString *badJSON = [[NSString alloc] initWithFormat:@"{\"bad\":\"1\",\"bad2\":\"2\"}"];
	Question* question = [testSet parseQuestions:badJSON];
	STAssertTrue(question == nil , @"unexpected value" );
	[badJSON release];
	
}

/**
	Test that we can get the second question after the initial one
 */
- (void) testNextQuestion{
	Question* question1 = [testSet getQuestion:1]; 	// get the first question
	STAssertTrue([question1.question isEqualToString:@"What is a prime number?"], @"unexpected value" );
	Question* question2 = [testSet getQuestion:2];  // now get the second one
	STAssertTrue([question2.question isEqualToString:@"What is an even number?"], @"unexpected value");
	STAssertTrue([question2.correctAns isEqualToString:@"2"], @"unexpected value");
	STAssertTrue([question2.wrong1 isEqualToString:@"3"], @"unexpected value" );
	STAssertTrue([question2.wrong2 isEqualToString:@"5"], @"unexpected value" );
	STAssertTrue([question2.wrong3 isEqualToString:@"7"], @"unexpected value" );
}


/**
	Test that we can't go out of bounds when requesting a question
 */
- (void) testInvalidQuestionNumber{
	Question* questionNil = [testSet getQuestion:16]; // there are only 3 questions in the testJSON
	STAssertTrue(questionNil == nil, @"unexpected value");
}


/**
	Test the parseAttributes function
 */
- (void) testParseAttributes{
	NSString* testJSON = [[NSString alloc] initWithFormat:@"{\"setID\":\"1\",\"category\":\"History\"}"];
	[testSet parseAttributes:testJSON];
	STAssertTrue([testSet.category isEqualToString:@"History"],@"unexpected value");
}


#else                           // all code under test must be linked into the Unit Test bundle

- (void) testMath {
    
    STAssertTrue((1+1)==2, @"Compiler isn't feeling well today :-(" );
    
}


#endif


@end
