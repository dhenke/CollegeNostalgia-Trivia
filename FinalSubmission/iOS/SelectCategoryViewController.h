//
//  SelectCategoryViewController.h
//  iOS
//
//  Created by Dave Henke on 3/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionViewController.h"
#import "RootViewController.h"

@interface SelectCategoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	NSArray* listData;
	QuestionViewController *questionViewController;
}

@property (retain,nonatomic) NSArray *listData;
@property (retain, nonatomic) QuestionViewController *questionViewController;
@property (nonatomic, retain) NSMutableData *receivedData;

- (NSString *)dataFilePath;
-(void) sendRequest;
-(void)removeCategoryView;

	
@end
