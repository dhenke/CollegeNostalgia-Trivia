//
//  QuestionSet.h
//  iOS
//
//  Created by Dave Henke and Ryan Sullivan on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Question.h"

/*
 *	Data object that contains our category, setID number,
 *		and an array of 15 question objects
 */
@interface QuestionSet : NSObject {
	NSString *category;
	int maxQuestions;
	NSMutableArray *questionArray;
}

@property (nonatomic, retain) NSString* category;
@property (nonatomic, retain) NSMutableArray* questionArray;
@property (nonatomic) int maxQuestions;

/* Function Declarations */
-(id)initWithCategory:(NSString*) c;
-(NSString *) grabJSON:(NSString *)c;
-(void)parseAttributes: (NSString*) JSONString;
-(Question*)parseQuestions: (NSString*)JSONString;
-(Question*)getQuestion:(int)index;
- (NSString *)dataFilePath;

@end
