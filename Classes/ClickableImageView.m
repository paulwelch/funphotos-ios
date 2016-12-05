//
//  ClickableImageView.m
//  FunPhotos
//
//  Created by Paul Welch on 4/12/09.
//  Copyright MetriWorks 2009. All rights reserved.
//

#import "ClickableImageView.h"


@implementation ClickableImageView

@synthesize delegate;

- (id) init
{
	self = [super init];
	if (self != nil) 
	{
        self.userInteractionEnabled = YES;
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) 
	{
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    if([delegate respondsToSelector:@selector(imageClicked)]) {
        [delegate imageClicked];
    }    
}

- (void)dealloc 
{
    [super dealloc];
}


@end
