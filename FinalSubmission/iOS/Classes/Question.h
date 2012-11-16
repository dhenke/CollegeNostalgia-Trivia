//
//  Question.h
//  iOS
//
//  Created by Dave Henke and Ryan Sullivan on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
	Question data object
	Contains:
			*question text
			*correct answer text
			*incorrect answer textx3
			*question number
			*correct answer button index
 */
@interface Question : NSObject {
	NSString *question, *correctAns, *wrong1, *wrong2, *wrong3;
	int questionNumber, correctButton;
}

@property (nonatomic, retain) NSString* question;
@property (nonatomic, retain) NSString* correctAns;
@property (nonatomic, retain) NSString* wrong1;
@property (nonatomic, retain) NSString* wrong2;
@property (nonatomic, retain) NSString* wrong3;
@property (nonatomic) int questionNumber;
@property (nonatomic) int correctButton;

/* Function declaration */
- (id) initWithJSON:(NSDictionary*)JSONObjects andQuestionNumber:(int) n;

@end
