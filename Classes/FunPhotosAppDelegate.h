//
//  FunPhotosAppDelegate.h
//  FunPhotos
//
//  Created by Paul Welch on 1/10/09.
//  Copyright MetriWorks 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIPopoverController.h>
#import "PhotoEffectViewController.h"

@class FunPhotosViewController;

@interface FunPhotosAppDelegate : NSObject <UIApplicationDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    UIWindow *window;
	FunPhotosViewController *viewController;
    UIImagePickerController *imageCaptureController;
	UIPopoverController *popoverController;
	PhotoEffectViewController *imageViewController;
	Boolean flipImage;
	UIImage *originalImage;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet FunPhotosViewController *viewController;
@property (nonatomic, retain) IBOutlet UIImagePickerController *imageCaptureController;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet PhotoEffectViewController *imageViewController;
@property (nonatomic) Boolean flipImage;
@property (nonatomic, retain) UIImage *originalImage;

- (void)applicationDidFinishLaunching:(UIApplication *)application;
- (void)captureImage;
- (void)openImage;
- (void)imagePickerController:(UIImagePickerController *)pickerView didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)pickerView;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;  
- (void)saveImage;
- (void)applyEffects:(int)emphasis brightness:(int)brightness contrast:(int)contrastLevel red:(int)redLevel green:(int)greenLevel blue:(int)blueLevel invert:(bool)invert grayscale:(bool)grayscale distortEffect:(int)distortEffect;
@end

