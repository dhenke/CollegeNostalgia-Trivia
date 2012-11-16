//
//  User.h
//  iOS
//
//  Created by Ryan Sullivan on 3/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kFilename @"data.plist"

@interface User : NSObject {
	NSString* username;
	NSString* password;
	NSString* email;
	NSString* md5pass;
	NSString* userID;
	NSString* errorString;
	NSString* responseString;
}

@property (nonatomic, retain) NSString* username;
@property (nonatomic, retain) NSString* password;
@property (nonatomic, retain) NSString* email;
@property (nonatomic, retain) NSString* md5pass;
@property (nonatomic, retain) NSString* userID;
@property (nonatomic, retain) NSString* errorString;
@property (nonatomic, retain) NSString* responseString;

-(id)init;
-(BOOL) checkUsername;
-(BOOL) checkPassword;
-(BOOL) checkEmail;
-(void) getMD5;
-(BOOL) sendRegisterRequest;
-(BOOL) sendLogInRequest;
-(void)storeUser:(NSString *)responseString;
-(BOOL)unregisterUser:(NSString *)uname andID:(NSString *)uID andEmail:(NSString *)emailAddr;
-(NSString *)dataFilePath;

@end
