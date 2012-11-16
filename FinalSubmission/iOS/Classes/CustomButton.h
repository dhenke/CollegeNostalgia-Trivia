//
//  CustomButton.h
//  iOS
//
//  Created by Dave Henke on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomButton : UIButton {

}

enum color {
	RED,GREEN,BLUE
};


- (void)setSelectedImageType:(int)which;

@end
