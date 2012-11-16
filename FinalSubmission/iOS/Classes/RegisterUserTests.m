//
//  RegisterUserTests.m
//  iOS
//
//  Created by Ryan Sullivan on 3/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RegisterUserTests.h"

@class RegisterViewController;


@implementation RegisterUserTests

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

/**
 Tests that the application loads
 */
- (void) testAppDelegate {
    id yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(yourApplicationDelegate, @"UIApplication failed to find the AppDelegate");
}

/**
 Tests that, given valid parameters, we allow a request to be sent to the server
 */
- (void) testValidParams{
	User* newUser = [[User alloc]init];
	//set out parameters
	newUser.username = [[NSString alloc] initWithString:@"test"];
	newUser.password = [[NSString alloc] initWithString:@"password"];
	newUser.email = [[NSString alloc] initWithString:@"test@gmail.com"];
	STAssertTrue([newUser checkUsername] == YES, @"Bad username" ); //tests checkUsername()
	STAssertTrue([newUser checkPassword] == YES, @"Bad password" ); //tests checkPassword()
	STAssertTrue([newUser checkEmail] == YES, @"Bad email" ); //tests checkEmail()
}

/**
 Tests that we can detect a bad username
 */
- (void) testBadUsername{
	User* newUser = [[User alloc]init];
	//set out parameters
	newUser.username = [[NSString alloc] initWithString:@"t"];
	newUser.password = [[NSString alloc] initWithString:@"password"];
	newUser.email = [[NSString alloc] initWithString:@"test@gmail.com"];
	STAssertTrue([newUser checkUsername] == NO, @"Didnt detect bad username" ); //tests checkUsername()
	STAssertTrue([newUser checkPassword] == YES, @"Bad password" ); //tests checkPassword()
	STAssertTrue([newUser checkEmail] == YES, @"Bad email" );//tests checkEmail()
}

/**
 Tests that we can detect a bad password
 */
- (void) testBadPassword{
	User* newUser = [[User alloc]init];
	//set out parameters
	newUser.username = [[NSString alloc] initWithString:@"test"];
	newUser.password = [[NSString alloc] initWithString:@"p"];
	newUser.email = [[NSString alloc] initWithString:@"test@gmail.com"];
	STAssertTrue([newUser checkUsername] == YES, @"Bad username" ); //tests checkUsername()
	STAssertTrue([newUser checkPassword] == NO, @"Didnt detect bad password" ); //tests checkPassword()
	STAssertTrue([newUser checkEmail] == YES, @"Bad email" ); //tests checkEmail()
}

/**
 Tests that we  can detect a bad email
 */
- (void) testBadEmail{
	User* newUser = [[User alloc]init];
	//set out parameters
	newUser.username = [[NSString alloc] initWithString:@"test"];
	newUser.password = [[NSString alloc] initWithString:@"password"];
	newUser.email = [[NSString alloc] initWithString:@"test"];
	STAssertTrue([newUser checkUsername] == YES, @"Bad username" ); //tests checkUsername()
	STAssertTrue([newUser checkPassword] == YES, @"Bad password" ); //tests checkPassword()
	STAssertTrue([newUser checkEmail] == NO, @"Didnt detect bad email" ); //tests checkEmail()
}

/**
 Tests that we get a proper MD5 hash
 */
- (void) testMD5{
	User* newUser = [[User alloc]init];
	//set out parameters
	newUser.password = [[NSString alloc] initWithString:@"password"];	
	STAssertTrue([newUser checkPassword] == YES, @"Bad password" ); //tests checkPassword()
	STAssertTrue([newUser.md5pass isEqualToString:@"5f4dcc3b5aa765d61d8327deb882cf99"] == YES, @"Bad MD5" );
}

- (void) testUnregister{
	User* newUser = [[User alloc]init];
	STAssertTrue( [newUser unregisterUser:@"ryan" andID:@"91" andEmail:@"ryan@gmail.com"] == NO, @"Couldn't unregister");
}

- (void) testRegister{
	User* newUser = [[User alloc]init];
	newUser.username = @"iphonetestuser";
	newUser.password = @"password";
	newUser.email = @"iphonetestuser";
	[newUser getMD5];
	
	STAssertTrue([newUser sendRegisterRequest] == YES, @"Didnt successfully register");
	STAssertTrue([newUser unregisterUser:newUser.username andID:newUser.userID andEmail:newUser.email] == YES, @"Couldn't unregister");
	
	
}


#else                           // all code under test must be linked into the Unit Test bundle

- (void) testMath {
    
    STAssertTrue((1+1)==2, @"Compiler isn't feeling well today :-(" );
    
}


#endif


@end
