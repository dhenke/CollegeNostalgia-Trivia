//
//  Question.m
//  iOS
//
//  Created by Dave Henke and Ryan Sullivan on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Question.h"
#import "JSON/JSON.h"


@implementation Question

@synthesize question;
@synthesize correctAns;
@synthesize wrong1;
@synthesize wrong2;
@synthesize wrong3;
@synthesize questionNumber;
@synthesize correctButton;


/**
	Constructor
	creates a question object from the provided JSON object and question number
	@param JSONObject - NSDictionary object that represents a JSON string
	@param n - integer containing question number requested
	@returns self - pointer to Question object we have just created
 */
- (id) initWithJSON:(NSDictionary*)JSONObjects andQuestionNumber:(int) n{
	if (self = [super init]) {
		questionNumber = n;
		
		//create dictionary for the question we care about
		NSDictionary* questionObjects = [JSONObjects objectForKey:[NSString stringWithFormat:@"question%i",n]];
		
		//retrieve attributes for our new dictionary
		question = [questionObjects objectForKey:@"question"];
		if (question == nil)
			return nil;
		[question retain];
		correctAns = [questionObjects objectForKey:@"correctAns"];
		if (correctAns == nil)
			return nil;
		[correctAns retain];
		wrong1 = [questionObjects objectForKey:@"wrong1"];
		if (wrong1 == nil)
			return nil;
		[wrong1 retain];
		wrong2 = [questionObjects objectForKey:@"wrong2"];
		if (wrong2 == nil)
			return nil;
		[wrong2 retain];
		wrong3 = [questionObjects objectForKey:@"wrong3"];
		if (wrong3 == nil)
			return nil;
		[wrong3 retain];
		correctButton = (arc4random() % 4)+1;
	}
	return self;
}	

@end
