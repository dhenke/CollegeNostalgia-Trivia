//
//  CustomButton.m
//  iOS
//
//  Created by Dave Henke on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomButton.h"


@implementation CustomButton

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    UIImage *grayBack = [[UIImage imageNamed:@"ButtonBack.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
	[self setBackgroundImage:grayBack forState:UIControlStateNormal];
	
	UIImage *yellowBack = [[UIImage imageNamed:@"ButtonBackHigh.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
	[self setBackgroundImage:yellowBack forState:UIControlStateHighlighted];
	[self setBackgroundImage:yellowBack forState:(UIControlStateHighlighted|UIControlStateSelected)];
	
	UIImage *blueBack = [[UIImage imageNamed:@"ButtonBackBlue.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
	[self setBackgroundImage:blueBack forState:UIControlStateSelected];
	
	
	[self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[self setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
	[self setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
}

- (void)setSelectedImageType:(int)which{
	UIImage *newImage;
	if (which == RED) newImage = [[UIImage imageNamed:@"ButtonBackRed.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
	else if(which == GREEN) newImage = [[UIImage imageNamed:@"ButtonBackGreen.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
	else if(which == BLUE) newImage = [[UIImage imageNamed:@"ButtonBackBlue.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
	[self setBackgroundImage:newImage forState:UIControlStateSelected];
}

- (void)dealloc {
    [super dealloc];
}




@end
