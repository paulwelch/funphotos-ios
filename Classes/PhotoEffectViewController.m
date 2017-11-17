//
//  FunPhotosViewController.m
//  FunPhotos
//
//  Created by Paul Welch on 1/10/09.
//  Copyright MetriWorks 2009. All rights reserved.
//

#import "PhotoEffectViewController.h"
#import "FunPhotosAppDelegate.h"

@interface PhotoEffectViewController(PrivateMethods)
- (NSString *)base64Encoding:(NSData *)data lineLength:(unsigned int)lineLength;
- (NSString *)composeEmail:(UIImage *)image;
- (void)imageDidLoad;
- (void)showEffectPanel;
- (void)hideEffectPanel;
- (void)layoutForCurrentOrientation:(BOOL)animated;
@end

@implementation PhotoEffectViewController
@synthesize imageView;
@synthesize busy;
@synthesize contentView;

- (void)setBusy:(Boolean)input
{
	busy = input;
	if(busy)
	{
		[activityIndicator startAnimating];
	}
	else
	{
		[activityIndicator stopAnimating];
	}
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	//initialize
	
	//CGFloat w = emphasisSlider.frame.size.width;
	//CGFloat h = emphasisSlider.frame.size.height;
	//[emphasisSlider setFrame:CGRectMake(CGRectGetMaxX(self.view.bounds) - 20, 
	//									CGRectGetMinY(self.view.bounds) + 20,
	//									w,
	//									h)];
	emphasisSlider.transform = CGAffineTransformRotate(emphasisSlider.transform, 270.0/180*M_PI);

	redLevelSlider.transform = CGAffineTransformRotate(redLevelSlider.transform, 270.0/180*M_PI);
	greenLevelSlider.transform = CGAffineTransformRotate(greenLevelSlider.transform, 270.0/180*M_PI);
	blueLevelSlider.transform = CGAffineTransformRotate(blueLevelSlider.transform, 270.0/180*M_PI);
	brightnessLevelSlider.transform = CGAffineTransformRotate(brightnessLevelSlider.transform, 270.0/180*M_PI);
	contrastLevelSlider.transform = CGAffineTransformRotate(contrastLevelSlider.transform, 270.0/180*M_PI);
	
	//set activity indicator hidden to start
	[self setBusy:NO];
	
	//hide panel to start because don't want to see the animation on initial load
	effectControlPanel.hidden = TRUE;
	imageLoaded = FALSE;
	[self displayEmphasisSlider:TRUE];
	[self hideEffectPanel];	
	[self resetEffects];
	
	NSMutableArray *items = [[toolbar.items mutableCopy] autorelease];
	
	if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
		//No camera, disable camera button
		cameraButton.enabled = NO;
		
		//Remove button from button bar (no hidden property???)
		[items removeObject:cameraButton];
	}
	
	toolbar.items = items;
	
	[imageView setDelegate:self];
	
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)layoutForCurrentOrientation:(BOOL)animated
{
    CGFloat animationDuration = animated ? 0.2 : 0.0;
    // by default content consumes the entire view area
    CGRect contentFrame = self.view.bounds;
    
    // And finally animate the changes, running layout for the content view if required.
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         contentView.frame = contentFrame;
                         [contentView layoutIfNeeded];
                     }];
}

-(void)viewDidUnload
{
    self.contentView = nil;
}


- (IBAction)capturePhoto 
{
	FunPhotosAppDelegate *delegate = (FunPhotosAppDelegate *)[[UIApplication sharedApplication] delegate];
	[delegate captureImage];
}

- (void)imageDidLoad
{
	@synchronized(self)
	{
		imageLoaded = TRUE;
		[instructionText setHidden:TRUE];
		[self displayEmphasisSlider:TRUE];
	}
}

- (IBAction)openPhoto 
{
    //open from photo album
	FunPhotosAppDelegate *delegate = (FunPhotosAppDelegate *)[[UIApplication sharedApplication] delegate];
	[delegate openImage];
}

- (IBAction)email 
{
	FunPhotosAppDelegate *delegate = (FunPhotosAppDelegate *)[[UIApplication sharedApplication] delegate];
	UIImage *image = delegate.imageViewController.imageView.image;
	NSString *emailStr = [self composeEmail:image];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailStr]];
	
	exit(0);
}

- (IBAction)save 
{
	//do the save
	FunPhotosAppDelegate *delegate = (FunPhotosAppDelegate *)[[UIApplication sharedApplication] delegate];
	[delegate saveImage];
}

- (IBAction)showMenu 
{
	if(imageLoaded)
	{
		UIActionSheet *actionSheet = [[UIActionSheet alloc]
									  initWithTitle:@""
									  delegate:self
									  cancelButtonTitle:@"Cancel"
									  destructiveButtonTitle:nil
									  otherButtonTitles:@"Save Photo", @"Email Photo", nil];
		actionSheet.tag	= 10;
		[actionSheet showInView:self.view];
		[actionSheet release];
	}
}

- (IBAction)distort
{
	if(imageLoaded)
	{
		UIActionSheet *actionSheet = [[UIActionSheet alloc]
									  initWithTitle:@""
									  delegate:self
									  cancelButtonTitle:@"Cancel"
									  destructiveButtonTitle:nil
									  otherButtonTitles:@"None", @"1 Wave", @"2 Wave", nil];
		actionSheet.tag	= 20;
		[actionSheet showInView:self.view];
		[actionSheet release];
	}
}

- (IBAction)emphasisChanged
{
	@synchronized(self)
	{
		int br = (int)brightnessLevelSlider.value;
		int c = (int)contrastLevelSlider.value;
		int r = (int)redLevelSlider.value;
		int g = (int)greenLevelSlider.value;
		int b = (int)blueLevelSlider.value;
		bool invert = (bool)invertSwitch.isOn;
		bool gray = (bool)grayscaleSwitch.isOn;
		int e = (int)emphasisSlider.value;

		if (e != currentEmphasis) 
		{
			currentEmphasis = e;
			FunPhotosAppDelegate *delegate = (FunPhotosAppDelegate *)[[UIApplication sharedApplication] delegate];
			[delegate applyEffects:e brightness:br contrast:c red:r green:g blue:b invert:invert grayscale:gray  distortEffect:currentDistortEffect];
		}
	}
}

- (void)resetEffects
{
	currentEmphasis = 0;
	currentEmphasis = 0;
	currentRedLevel = 0;
	currentGreenLevel = 0;
	currentBlueLevel = 0;
	currentBrightnessLevel = 0;
	currentContrastLevel = 0;
	currentinvert = FALSE;
	currentGrayscale = FALSE;
	currentDistortEffect = 0;

	[brightnessLevelSlider setValue:0];
	[contrastLevelSlider setValue:0];
	[redLevelSlider setValue:0];
	[greenLevelSlider setValue:0];
	[blueLevelSlider setValue:0];
	[invertSwitch setOn:FALSE];
	[grayscaleSwitch setOn:FALSE];

	[emphasisSlider setValue:0];
}

- (IBAction)redLevelChanged
{
	@synchronized(self)
	{
		int br = (int)brightnessLevelSlider.value;
		int c = (int)contrastLevelSlider.value;
		int r = (int)redLevelSlider.value;
		int g = (int)greenLevelSlider.value;
		int b = (int)blueLevelSlider.value;
		bool invert = (bool)invertSwitch.isOn;
		bool gray = (bool)grayscaleSwitch.isOn;
		int e = (int)emphasisSlider.value;
		
		if (r != currentRedLevel) 
		{
			currentRedLevel = r;
			FunPhotosAppDelegate *delegate = (FunPhotosAppDelegate *)[[UIApplication sharedApplication] delegate];
			[delegate applyEffects:e brightness:br contrast:c red:r green:g blue:b invert:invert grayscale:gray distortEffect:currentDistortEffect];
		}
	}
}

- (IBAction)greenLevelChanged
{
	@synchronized(self)
	{
		int br = (int)brightnessLevelSlider.value;
		int c = (int)contrastLevelSlider.value;
		int r = (int)redLevelSlider.value;
		int g = (int)greenLevelSlider.value;
		int b = (int)blueLevelSlider.value;
		bool invert = (bool)invertSwitch.isOn;
		bool gray = (bool)grayscaleSwitch.isOn;
		int e = (int)emphasisSlider.value;
		
		if (g != currentGreenLevel) 
		{
			currentGreenLevel = g;
			FunPhotosAppDelegate *delegate = (FunPhotosAppDelegate *)[[UIApplication sharedApplication] delegate];
			[delegate applyEffects:e brightness:br contrast:c red:r green:g blue:b invert:invert grayscale:gray distortEffect:currentDistortEffect];
		}
	}
}

- (IBAction)blueLevelChanged
{
	@synchronized(self)
	{
		int br = (int)brightnessLevelSlider.value;
		int c = (int)contrastLevelSlider.value;
		int r = (int)redLevelSlider.value;
		int g = (int)greenLevelSlider.value;
		int b = (int)blueLevelSlider.value;
		bool invert = (bool)invertSwitch.isOn;
		bool gray = (bool)grayscaleSwitch.isOn;
		int e = (int)emphasisSlider.value;
		
		if (b != currentBlueLevel) 
		{
			currentBlueLevel = b;
			FunPhotosAppDelegate *delegate = (FunPhotosAppDelegate *)[[UIApplication sharedApplication] delegate];
			[delegate applyEffects:e brightness:br contrast:c red:r green:g blue:b invert:invert grayscale:gray distortEffect:currentDistortEffect];
		}
	}
}

- (IBAction)brightnessLevelChanged
{
	@synchronized(self)
	{
		int br = (int)brightnessLevelSlider.value;
		int c = (int)contrastLevelSlider.value;
		int r = (int)redLevelSlider.value;
		int g = (int)greenLevelSlider.value;
		int b = (int)blueLevelSlider.value;
		bool invert = (bool)invertSwitch.isOn;
		bool gray = (bool)grayscaleSwitch.isOn;
		int e = (int)emphasisSlider.value;
		
		if (br != currentBrightnessLevel) 
		{
			currentBrightnessLevel = br;
			FunPhotosAppDelegate *delegate = (FunPhotosAppDelegate *)[[UIApplication sharedApplication] delegate];
			[delegate applyEffects:e brightness:br contrast:c red:r green:g blue:b invert:invert grayscale:gray distortEffect:currentDistortEffect];
		}
	}
}

- (IBAction)contrastLevelChanged
{
	@synchronized(self)
	{
		int br = (int)brightnessLevelSlider.value;
		int c = (int)contrastLevelSlider.value;
		int r = (int)redLevelSlider.value;
		int g = (int)greenLevelSlider.value;
		int b = (int)blueLevelSlider.value;
		bool invert = (bool)invertSwitch.isOn;
		bool gray = (bool)grayscaleSwitch.isOn;
		int e = (int)emphasisSlider.value;
		
		if (c != currentContrastLevel) 
		{
			currentContrastLevel = c;
			FunPhotosAppDelegate *delegate = (FunPhotosAppDelegate *)[[UIApplication sharedApplication] delegate];
			[delegate applyEffects:e brightness:br contrast:c red:r green:g blue:b invert:invert grayscale:gray distortEffect:currentDistortEffect];
		}
	}
}

- (IBAction)invertChanged
{
	@synchronized(self)
	{
		int br = (int)brightnessLevelSlider.value;
		int c = (int)contrastLevelSlider.value;
		int r = (int)redLevelSlider.value;
		int g = (int)greenLevelSlider.value;
		int b = (int)blueLevelSlider.value;
		bool invert = (bool)invertSwitch.isOn;
		bool gray = (bool)grayscaleSwitch.isOn;
		int e = (int)emphasisSlider.value;
		
		if (invert != currentinvert) 
		{
			currentinvert = invert;
			FunPhotosAppDelegate *delegate = (FunPhotosAppDelegate *)[[UIApplication sharedApplication] delegate];
			[delegate applyEffects:e brightness:br contrast:c red:r green:g blue:b invert:invert grayscale:gray distortEffect:currentDistortEffect];
		}
	}
}

- (IBAction)grayscaleChanged
{
	@synchronized(self)
	{
		int br = (int)brightnessLevelSlider.value;
		int c = (int)contrastLevelSlider.value;
		int r = (int)redLevelSlider.value;
		int g = (int)greenLevelSlider.value;
		int b = (int)blueLevelSlider.value;
		bool invert = (bool)invertSwitch.isOn;
		bool gray = (bool)grayscaleSwitch.isOn;
		int e = (int)emphasisSlider.value;
		
		if (gray != currentGrayscale) 
		{
			currentGrayscale = gray;
			FunPhotosAppDelegate *delegate = (FunPhotosAppDelegate *)[[UIApplication sharedApplication] delegate];
			[delegate applyEffects:e brightness:br contrast:c red:r green:g blue:b invert:invert grayscale:gray distortEffect:currentDistortEffect];
		}
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (!(buttonIndex == [actionSheet cancelButtonIndex])) {
		switch (actionSheet.tag) {
			case 10:
				if(buttonIndex == 0)
				{
					//save button
					[self save];
				}
				else if(buttonIndex == 1)
				{
					//email button
					[self email];
				}
				break;
			case 20:
				if (buttonIndex != currentDistortEffect) 
				{
					int br = (int)brightnessLevelSlider.value;
					int c = (int)contrastLevelSlider.value;
					int r = (int)redLevelSlider.value;
					int g = (int)greenLevelSlider.value;
					int b = (int)blueLevelSlider.value;
					bool invert = (bool)invertSwitch.isOn;
					bool gray = (bool)grayscaleSwitch.isOn;
					int e = (int)emphasisSlider.value;
				
					currentDistortEffect = buttonIndex;
					[self displayEmphasisSlider:TRUE];
					FunPhotosAppDelegate *delegate = (FunPhotosAppDelegate *)[[UIApplication sharedApplication] delegate];
					[delegate applyEffects:e brightness:br contrast:c red:r green:g blue:b invert:invert grayscale:gray distortEffect:currentDistortEffect];
				}
				break;
			default:
				break;
		}		
	}
}

//TODO: move this to a util class
- (NSString *)composeEmail:(UIImage *)image
{
	NSData   *pngImage = UIImagePNGRepresentation(image);
	
	NSString *base64String = [self base64Encoding:pngImage lineLength:0];
	
	NSString *body       = [@"" stringByAppendingFormat:@"<HTML><HEAD><TITLE>Fun Photo</TITLE></HEAD><BODY><b><img src='data:image/png;base64,%@' alt='Fun Photo'/></b></BODY></HTML>", base64String];
	NSString *encoded    = [body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *subject    = [@"Fun Photo" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *urlString  = [@"" stringByAppendingFormat:@"mailto:%@?subject=%@&body=%@", @"", subject, encoded];
	
	//http://discussions.apple.com/thread.jspa?threadID=1891952
	
	return urlString;
}

- (void)imageClicked
{
	
	if(effectControlPanel.hidden)
	{
		[self showEffectPanel];
	}
	else
	{
		[self hideEffectPanel];
	}
}

- (void)displayEmphasisSlider:(bool)display
{
	if (currentDistortEffect != 0 && display) 
	{
		emphasisSlider.hidden = FALSE;
	}
	else 
	{
		emphasisSlider.hidden = TRUE;
	}

}

- (void)showEffectPanel
{
	if(imageLoaded)
	{
		effectControlPanel.hidden = FALSE;
		
		[UIView beginAnimations:NULL context:NULL];
		[UIView setAnimationDuration:0.4];
		[UIView setAnimationDelegate: self];
		[UIView setAnimationDidStopSelector:@selector(openEffectPanelAnimationDidStop:finished:context:)];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		CGRect rect = [effectControlPanel frame];
		rect.origin.x += 134;
		[effectControlPanel setFrame:rect];
		[UIView commitAnimations];	
	}
}

- (void)hideEffectPanel
{
	[UIView beginAnimations:NULL context:NULL];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationDelegate:self ];
	[UIView setAnimationDidStopSelector:@selector(closeEffectPanelAnimationDidStop:finished:context:)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	CGRect rect = [effectControlPanel frame];
	rect.origin.x -= 134;
	[effectControlPanel setFrame:rect];
	[UIView commitAnimations];	
}

- (void) openEffectPanelAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
}

- (void) closeEffectPanelAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	//hide after animation finishes
	effectControlPanel.hidden = TRUE;
}

//TODO: move this to a util class
- (NSString *) base64Encoding:(NSData *)data lineLength:(unsigned int)lineLength
{
	static char encodingTable[64] = {
		'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
		'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
		'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
	'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/' };
	
	const unsigned char *bytes = [data bytes];
	NSMutableString *result = [NSMutableString stringWithCapacity:[data length]];
	unsigned long ixtext = 0;
	unsigned long lentext = [data length];
	long ctremaining = 0;
	unsigned char inbuf[3], outbuf[4];
	unsigned short i = 0;
	unsigned short charsonline = 0, ctcopy = 0;
	unsigned long ix = 0;
	
	while( YES ) 
	{
		ctremaining = lentext - ixtext;
		if( ctremaining <= 0 ) break;
		
		for( i = 0; i < 3; i++ ) 
		{
			ix = ixtext + i;
			if( ix < lentext ) inbuf[i] = bytes[ix];
			else inbuf [i] = 0;
		}
		
		outbuf [0] = (inbuf [0] & 0xFC) >> 2;
		outbuf [1] = ((inbuf [0] & 0x03) << 4) | ((inbuf [1] & 0xF0) >> 4);
		outbuf [2] = ((inbuf [1] & 0x0F) << 2) | ((inbuf [2] & 0xC0) >> 6);
		outbuf [3] = inbuf [2] & 0x3F;
		ctcopy = 4;
		
		switch( ctremaining ) 
		{
			case 1:
				ctcopy = 2;
				break;
			case 2:
				ctcopy = 3;
				break;
		}
		
		for( i = 0; i < ctcopy; i++ )
			[result appendFormat:@"%c", encodingTable[outbuf[i]]];
		
		for( i = ctcopy; i < 4; i++ )
			[result appendString:@"="];
		
		ixtext += 3;
		charsonline += 4;
		
		if( lineLength > 0 ) {
			if( charsonline >= lineLength ) {
				charsonline = 0;
				[result appendString:@"\n"];
			}
		}
	}
	
	return [NSString stringWithString:result];
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

- (void)dealloc {
    [contentView release]; contentView = nil;
    [super dealloc];
}

@end
