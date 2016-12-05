//
//  FunPhotosAppDelegate.m
//  FunPhotos
//
//  Created by Paul Welch on 1/10/09.
//  Copyright MetriWorks 2009. All rights reserved.
//

#import <CoreGraphics/CGContext.h>
#import <CoreGraphics/CGBitmapContext.h>
#import <UIKit/UIDevice.h>
#import <UIKit/UIPopoverController.h>

#import "FunPhotosAppDelegate.h"
#import "FunPhotosViewController.h"
#import "TwoWaveMirrorEffect.h"
#import "OneWaveMirrorEffect.h"
#import "EmphasizeColorEffect.h"

@interface FunPhotosAppDelegate(PrivateMethods)
- (void)setImageCaptureSource;
@end

@implementation FunPhotosAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize imageCaptureController;
@synthesize popoverController;
@synthesize imageViewController;
@synthesize flipImage;
@synthesize originalImage;

- (id) init 
{
    self = [super init];
	flipImage = NO; //set flip below based on image source
    return self;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{    
	[application setStatusBarHidden:YES];
	self.window = [[[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	
	[viewController setWantsFullScreenLayout:YES];
	[window addSubview:viewController.view];
	
	//view to get a new image from camera or photo library
	imageCaptureController = [[UIImagePickerController alloc] init];
	[imageCaptureController setToolbarHidden:YES];
	imageCaptureController.delegate = self;
	[imageCaptureController setWantsFullScreenLayout:YES];
	imageCaptureController.allowsEditing = NO;
	
	//If iPad, must be in a popover
	if ([[UIDevice currentDevice] systemVersion] >= @"3.2" &&
		[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	{
		popoverController = [[UIPopoverController alloc] initWithContentViewController:imageCaptureController]; 
	}
		 
	[self setImageCaptureSource];
	
	//view to display image
	imageViewController = [[PhotoEffectViewController alloc] init];	
	[imageViewController setWantsFullScreenLayout:YES];
	
	[window addSubview:imageCaptureController.view];
	[window addSubview:imageViewController.view];
	
	[window bringSubviewToFront:imageViewController.view];
	[window makeKeyAndVisible];
}

- (void)setImageCaptureSource
{
	//In case no camera, use the photo album as default source
	//note: always setting this first also prevents crash when using camera back-to-back, i.e. if previously set to camera, now it will be set to album before being set to camera again
	imageCaptureController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;		
	
	//check for camera hardware, in case running on ipod touch and other device that doesn't have one
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
#if TARGET_IPHONE_SIMULATOR 
		//sometimes isSourceTypeAvailable says there's a camera for the simulator, but camera doesn't work in simulator
		imageCaptureController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;		
#else		
		imageCaptureController.sourceType = UIImagePickerControllerSourceTypeCamera;
#endif
	}
}

- (void)openImage
{
	imageCaptureController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;		
	
	[window bringSubviewToFront:imageCaptureController.view];
	[viewController presentModalViewController:imageCaptureController animated:YES];
}

- (void)captureImage
{
	[self setImageCaptureSource];
	[window bringSubviewToFront:imageCaptureController.view];
	[viewController presentModalViewController:imageCaptureController animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
	[viewController dismissModalViewControllerAnimated:YES];
	
	imageViewController.busy = YES;	
	[window bringSubviewToFront:imageViewController.view];
	
	TwoWaveMirrorEffect *effect = [[TwoWaveMirrorEffect alloc] init];
	effect.emphasis = 0;
	self.originalImage = [effect scaleAndRotateImage:(UIImage *)image];
	
	imageViewController.imageView.image = [effect transformImage:(UIImage *)image];
	[effect release];
	[imageViewController resetEffects];
	[imageViewController imageDidLoad];
	
	//[self increaseEffect];
	imageViewController.busy = NO;
}

- (void)applyEffects:(int)emphasis brightness:(int)brightness contrast:(int)contrastLevel red:(int)redLevel green:(int)greenLevel blue:(int)blueLevel invert:(bool)invert grayscale:(bool)grayscale distortEffect:(int)distortEffect
{
	@synchronized(self)
	{
		//do warp effect		
		//TODO: make more generic
		UIImage *tmpImage;
		OneWaveMirrorEffect *oneWaveEffect;
		TwoWaveMirrorEffect *twoWaveEffect;
		switch (distortEffect) {
			case 0:
				break;
			case 1:
				oneWaveEffect = [[OneWaveMirrorEffect alloc] init];
				oneWaveEffect.emphasis = emphasis;
				tmpImage = [[oneWaveEffect transformImage:originalImage] retain];
				[oneWaveEffect release];
				break;
			case 2:
				twoWaveEffect = [[TwoWaveMirrorEffect alloc] init];
				twoWaveEffect.emphasis = emphasis;
				tmpImage = [[twoWaveEffect transformImage:originalImage] retain];
				[twoWaveEffect release];
				break;
			default:
				break;
		}
		
		//apply color effects
		EmphasizeColorEffect *colorEffect = [[EmphasizeColorEffect alloc] init];
		colorEffect.brightnessLevel = brightness;
		colorEffect.contrastLevel = contrastLevel;
		colorEffect.redLevel = redLevel;
		colorEffect.greenLevel = greenLevel;
		colorEffect.blueLevel = blueLevel;
		colorEffect.invert = invert;
		colorEffect.grayscale = grayscale;
		UIImage *tmpColorImage;
		if (distortEffect == 0) 
		{
			tmpColorImage = [[colorEffect transformImage:originalImage] retain];
		}
		else 
		{
			tmpColorImage = [[colorEffect transformImage:tmpImage] retain];
			[tmpImage release];
		}
		
		imageViewController.imageView.image = tmpColorImage;
		
		[colorEffect release];
		[tmpColorImage release];
		
		[imageViewController imageDidLoad];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)pickerView
{
	[viewController dismissModalViewControllerAnimated:YES];
	[window bringSubviewToFront:imageViewController.view];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation  
{  
    return YES;  
} 

- (void)saveImage
{	
	//save image
	UIImageWriteToSavedPhotosAlbum(imageViewController.imageView.image, self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
}

- (void)savedPhotoImage:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{    
    NSString *message = @"Photo was saved to your Saved Photos album";
    if (error) 
	{
        message = [error localizedDescription];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView  clickedButtonAtIndex:(NSInteger)buttonIndex {
	//after save, don't exit
}

- (void)dealloc 
{
	[imageViewController release];
    [imageCaptureController release];
	[viewController release];
	[originalImage release];
    [window release];
    [super dealloc];
}

@end
