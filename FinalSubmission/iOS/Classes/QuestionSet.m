//
//  QuestionSet.m
//  iOS
//
//  Created by Dave Henke and Ryan Sullivan on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QuestionSet.h"
#import "JSON/JSON.h"

//This is the maximum number of questions that our JSON string will contain


#define kFilename	@"data.plist"
#define MAX_QUESTIONS 15

@implementation QuestionSet

@synthesize category;
@synthesize questionArray;
@synthesize maxQuestions;


/**
	Constructor for out question set object.  The object will be initialized with
 		a JSON string containing setID, category, and 15 questions and answers.
 		From the JSON we will fill the attributes of the QuestionSet and each
 		question.
 */
-(id)initWithCategory:(NSString *)c{
	if (self = [super init]){
		
		maxQuestions = MAX_QUESTIONS;
		
		//retrieve our JSON object
		NSString *JSONString = [self grabJSON:c];
		questionArray = [[NSMutableArray alloc] initWithCapacity:maxQuestions];
		
		//fill attributes of QuestionSet object and Question objects
		[self parseAttributes:JSONString];
		[self parseQuestions:JSONString];
	}
	return self;
}

/**
	Connects to our Web Service and retrieves a JSON object containing 15 questions
 		and answers.
 	@param c - string containing the category we want
 	@returns jsonString - string containng the JSON we retrieve from the server
 */
  //TODO make this function return a JSON object based on a category
- (NSString *)grabJSON: (NSString*) c{
	//This portion of code is strictly for testing.  It is used to return a statis JSON that we already know the format of.
	if ([c isEqualToString:[[NSString alloc] initWithFormat:@"oldExampleJSON"]]) {
		NSString *tempURL =  @"http://triviarea.projects.cs.illinois.edu/oldExampleJSON.php";
		NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:tempURL]];
		NSURLResponse *resp = nil;
		NSError *err = nil;
		NSData *response = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &err];
		NSString *theString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]; 
		return theString;
		
	//this is the connection that the application actually makes
	}else {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		
		NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:[self dataFilePath]];
		NSString *postBody = [NSString stringWithFormat:@"userID=%@&category=%@", [array objectAtIndex:0],c];
		NSString *urlStr = @"http://triviarea.projects.cs.illinois.edu/retrieveQuestionSet.php";  
		NSMutableURLRequest *request;
		NSData *postData = [postBody dataUsingEncoding:NSASCIIStringEncoding];
		NSError *error;
		NSURLResponse *response;
		NSData *dataReply;
		id stringReply;
		
		request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:urlStr]];
		
		[request setHTTPMethod: @"POST"];
		[request setHTTPBody:postData];
		[request setValue:[NSString stringWithFormat:@"%d", [postBody length]] forHTTPHeaderField:@"Content-length"];
		
		dataReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		stringReply = (NSString *)[[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
		
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		
		return stringReply;	
	}
	return @"";
	

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
	Establishes the category and setID in our object from the given JSON string
 	@param JSONString - string containing our JSON object
 	@returns none
 */
-(void)parseAttributes: (NSString*) JSONString{
	NSDictionary* JSONObjects = [JSONString JSONValue];
	category = [JSONObjects objectForKey:@"category"];
	[category retain];
}

/**
	Builds each of our Question objects from our JSON object
 	@param JSONString - string containing our JSON object
 */
-(Question *)parseQuestions: (NSString*)JSONString{
	NSDictionary* JSONObjects = [JSONString JSONValue];
	questionArray = [NSMutableArray arrayWithCapacity:maxQuestions];
	Question *question;
	
	//For each question in JSON, create Question object and add it to our questionArray
	for (int i = 0; i < maxQuestions; i++) {
		question = [[Question alloc] initWithJSON:JSONObjects andQuestionNumber:i+1];
		if (question == nil)
			return nil;
		[questionArray addObject:question];
	}
	return question;
}



/**
	Helper function that returns the question object that represents a question
 		by the associated question number
 	@param index - int of the question number
 	@returns pointer to question object
 */
-(Question*)getQuestion:(int) index{
	if(index > maxQuestions) return nil;
	return [questionArray objectAtIndex:index-1];
}



@end
