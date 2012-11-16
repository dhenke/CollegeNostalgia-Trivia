//
//  LogInTests.m
//  iOS
//
//  Created by Ryan Sullivan on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LogInTests.h"


@implementation LogInTests

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

- (void) testAppDelegate {
    id yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(yourApplicationDelegate, @"UIApplication failed to find the AppDelegate");
}

- (void) testValidLogIn {
	User* newUser = [[User alloc]init];
	newUser.username = @"test";
	newUser.password = @"password";
	
	STAssertTrue([newUser sendLogInRequest] == YES, @"Didnt successfully register");
	STAssertTrue([newUser.responseString isEqualToString:@"48"] == YES, @"Invalid UserID response");
}

- (void) testLogInUserDNE {
	User* newUser = [[User alloc]init];
	newUser.username = @"A5fd8f0bv80garvarAG";
	newUser.password = @"password";
	
	STAssertTrue([newUser sendLogInRequest] == NO, @"Didnt successfully register");
	STAssertTrue([newUser.responseString isEqualToString:@"-1"] == YES, @"Invalid UserID response");
}

- (void) testLogInBadPass {
	User* newUser = [[User alloc]init];
	newUser.username = @"test";
	newUser.password = @"pass";
	
	STAssertTrue([newUser sendLogInRequest] == NO, @"Didnt successfully register");
	STAssertTrue([newUser.responseString isEqualToString:@"-1"] == YES, @"Invalid UserID response");
}


#else                           // all code under test must be linked into the Unit Test bundle

- (void) testMath {
    
    STAssertTrue((1+1)==2, @"Compiler isn't feeling well today :-(" );
    
}


#endif


@end
