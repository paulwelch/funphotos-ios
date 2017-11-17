//
//  FunPhotosViewController.m
//  FunPhotos
//
//  Created by Paul Welch on 1/10/09.
//  Copyright MetriWorks 2009. All rights reserved.
//

#import "FunPhotosViewController.h"

@interface FunPhotosViewController()

-(void)layoutForCurrentOrientation:(BOOL)animated;

@end

@implementation FunPhotosViewController

@synthesize contentView;

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

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

-(void)viewDidUnload
{
    self.contentView = nil;
}


- (void)dealloc
{
    [contentView release]; contentView = nil;
    [super dealloc];
}

@end
