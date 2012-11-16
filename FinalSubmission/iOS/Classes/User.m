//
//  User.m
//  iOS
//
//  Created by Ryan Sullivan on 3/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "User.h"
#import <CommonCrypto/CommonDigest.h>


@implementation User

@synthesize username;
@synthesize password;
@synthesize email;
@synthesize md5pass;
@synthesize userID;
@synthesize responseString;
@synthesize errorString;


/**
 Default constructor
 */
-(id)init{
	self = [super init];
	return self;	
}

/**
 Checks that the provided username is valid. The username is stored in the user object.
 Username must be greater than 3 chars and less than 25
 @return BOOL YES if valid, NO if not
 */
-(BOOL) checkUsername{
	if ([username length] < 3 || [username length] > 25) {
		return NO;
	}
	return YES;
}


/**
 Checks that the provided password is valid.  The password is stored in the user object
 Password must be greater then 4 chars and less then 25
 @return BOOL YES if valid, NO if not
 */
-(BOOL) checkPassword{
	if ([password length] < 4 || [password length] > 25) {
		return NO;
	}
	[self getMD5];
	return YES;
}


/**
 Checks that the provided email is valid.  The email is stored in the user object
 email must be a set of characters followed by "@", followed by characters, followed by ".", followed by characters
 @return BOOL YES if valid, NO if not
 */
-(BOOL) checkEmail{
	//validates email using regular expression
	NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
	
	//check length
	if ([email length] < 4 || [email length] > 40) {
		return NO;
	}
	//check regular expression
	if ([emailTest evaluateWithObject:email] == NO){
		return NO;
	}
	return YES;
}

/**
 Generate MD5 hash of our password and stores it in the user object.
 */
-(void) getMD5{
	const char *concat_str = [password UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( concat_str, strlen(concat_str), result );
	NSMutableString *hash = [NSMutableString string];
	
	//convert our hash data to a readable hex string
	for (int i = 0; i < 16; i++)
		[hash appendFormat:@"%02x", result[i]];
	
	md5pass = hash;
}

/**
 Makes a POST request containing the username, hashed password, and email to the server.
 connection didReceiveData takes care of the server response
 @return BOOL YES if connection is made, NO otherwise
 */
-(BOOL) sendRegisterRequest{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	//assume no error to start
	errorString = @"";
	
	NSString *postBody = [NSString stringWithFormat:@"username=%@&password=%@&email=%@", username, md5pass, email];
	//sending username, md5'd password, and email to server through post request
	NSString *urlStr = @"http://triviarea.projects.cs.illinois.edu/register.php";  
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
	responseString = stringReply;	
	
	if ([responseString isEqualToString:@"username or email in use"]) {
		//server responded, tell the user that the username or email is in use
		errorString = @"Username or Email in use";
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SetErrorLabel" object:self];
		return NO;
	}else {
		//server responded, valid request, responseString contains the new user's userID
		[self storeUser:responseString];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CloseRegisterView" object:self];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AdjustViewBack" object:self];
		//display alert that it was successful
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle: [NSString stringWithFormat:@"Registration Successful.\nWelcome, %@", username]
							  message: nil
							  delegate: nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	//update main menu to show that the user is signed in
	[[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateUsername" object:self];
	return YES;
	
}


/**
 Make a post request to the server attempting to authenticate the user's credentials.  If
	the server responds with -1, then the credentials provided were not valid.  Otherwise,
	the server responds with the userID, which we write to a file.
 @return BOOL Yes if the credentials are valid, no otherwise.
 */
-(BOOL) sendLogInRequest{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	[self getMD5];
	
	//sending username and md5'd password to server through post request
	NSString *postBody = [NSString stringWithFormat:@"username=%@&password=%@", username, md5pass];
	NSLog(@"Submitting %@", postBody);
	NSString *urlStr = @"http://triviarea.projects.cs.illinois.edu/appLogin.php";  
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
	responseString = stringReply;	
	
	if ([responseString isEqualToString:@"-1"]) {
		//server responded, unsuccessful log in
		errorString = @"Invalid Username or Password";
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SetErrorLabel" object:self];
		NSString *filePath = [self dataFilePath];
		if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
			NSFileManager *fileManager = [NSFileManager defaultManager];
			[fileManager removeItemAtPath:filePath error:nil];
		}
		return NO;
	}else {
		//server responded, successful log in
		[self storeUser:responseString];
	}
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	//update main menu to show that the user is signed in
	[[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateUsername" object:self];
	return YES;
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
 Writes our users information to our data.plist file after they successfully register
 @param responseString - response from the server.
 */
-(void)storeUser:(NSString *)responseStr{
	NSString *filePath = [self dataFilePath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		[fileManager removeItemAtPath:filePath error:nil];
	}
	
	NSMutableArray *array = [[NSMutableArray alloc] init]; 
	[array addObject:responseStr]; 
	[array addObject:username]; 
	[array addObject:@"NO"];
	[array addObject:password]; 
	[array writeToFile:[self dataFilePath] atomically:YES]; 
	[array release];
	
	userID = responseStr;
}


/**
 Unregisters a user.  THIS FUNCTION IS USED STRICTLY FOR TESTING PURPOSES
 */
-(BOOL)unregisterUser:(NSString *)uname andID:(NSString *)uID andEmail:(NSString *)emailAddr{
	//sending userID, username, and email to server through post request
    NSString *postBody = [NSString stringWithFormat:@"userID=%@&username=%@&email=%@",uID, uname, emailAddr ];
    NSString *urlStr = @"http://triviarea.projects.cs.illinois.edu/unregister.php";  
    NSMutableURLRequest *req;
    NSData *postData = [postBody dataUsingEncoding:NSASCIIStringEncoding];
    NSError *err;
    NSURLResponse *resp;
    NSData *dataReply;
    id stringReply;
	
	//format and package our request
    req = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:urlStr]];
    [req setHTTPMethod: @"POST"];
    [req setHTTPBody:postData];
    [req setValue:[NSString stringWithFormat:@"%d", [postBody length]] forHTTPHeaderField:@"Content-length"];
    
	//send our request, retrieve our reply
    dataReply = [NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:&err];
    stringReply = (NSString *)[[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
    // Some debug code, etc.
    
    if ([stringReply isEqualToString:@"cannot unregister"]) {
		return NO;
	}
	return YES;
}




@end
