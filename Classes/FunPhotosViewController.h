//
//  FunPhotosViewController.h
//  FunPhotos
//
//  Created by Paul Welch on 1/10/09.
//  Copyright MetriWorks 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface FunPhotosViewController : UIViewController <ADBannerViewDelegate> 
{
    UIView *contentView;
    ADBannerView *banner;
}

@property(nonatomic, retain) IBOutlet UIView *contentView;
@property(nonatomic, retain) IBOutlet ADBannerView *banner;

@end

