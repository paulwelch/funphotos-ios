//
//  FunPhotosViewController.m
//  FunPhotos
//
//  Created by Paul Welch on 1/10/09.
//  Copyright MetriWorks 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <Foundation/Foundation.h>
#import "ClickableImageView.h"

@interface PhotoEffectViewController : UIViewController <UIActionSheetDelegate> {
    IBOutlet ClickableImageView *imageView;
    IBOutlet UIToolbar *toolbar;
    IBOutlet UIBarButtonItem *cameraButton;
	IBOutlet UIBarButtonItem *doubleEffectButton;
	IBOutlet UIBarButtonItem *undoEffectButton;
	IBOutlet UISlider *emphasisSlider;
    IBOutlet UIView *effectControlPanel;
	IBOutlet UISlider *redLevelSlider;
	IBOutlet UISlider *greenLevelSlider;
	IBOutlet UISlider *blueLevelSlider;
	IBOutlet UISlider *brightnessLevelSlider;
	IBOutlet UISlider *contrastLevelSlider;
	IBOutlet UISwitch *invertSwitch;
	IBOutlet UISwitch *grayscaleSwitch;
	IBOutlet UILabel *instructionText;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    UIView *contentView;
	Boolean busy;
	int currentEmphasis;
	int currentRedLevel;
	int currentGreenLevel;
	int currentBlueLevel;
	int currentBrightnessLevel;
	int currentContrastLevel;
	Boolean currentinvert;
	Boolean currentGrayscale;
	int currentDistortEffect;
	Boolean imageLoaded;
}

- (IBAction)capturePhoto;
- (IBAction)openPhoto;
- (IBAction)distort;
- (IBAction)showMenu;
- (IBAction)emphasisChanged;
- (IBAction)redLevelChanged;
- (IBAction)greenLevelChanged;
- (IBAction)blueLevelChanged;
- (IBAction)brightnessLevelChanged;
- (IBAction)contrastLevelChanged;
- (IBAction)invertChanged;
- (IBAction)grayscaleChanged;
- (void)imageClicked;
- (void)imageDidLoad;  //TODO: figure out how to make this an event instead of a direct method call
- (void)resetEffects;
- (void)displayEmphasisSlider:(bool)display;

@property(nonatomic, retain) IBOutlet UIView *contentView;
@property (retain) IBOutlet ClickableImageView *imageView;
@property (assign) Boolean busy;

@end
