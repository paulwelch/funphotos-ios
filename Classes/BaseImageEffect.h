//
//  BaseImageEffect.h
//  FunPhotos
//
//  Created by Paul Welch on 2/25/09.
//  Copyright MetriWorks 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageEffect.h"

@interface BaseImageEffect : NSObject<ImageEffect> {
	//TODO: how do you make an abstract class here?
	Boolean flipImage;
	CGContextRef bitmapContext;
}

@property (nonatomic) Boolean flipImage;
@property CGContextRef bitmapContext;
//@property CGColorSpaceRef colorSpace;

- (int)calcFlippedRow:(int)row height:(size_t) height;
- (void)createBitmapContext:(UIImage *)image;
- (void)releaseBitmapContext;
- (UIImage *)scaleAndRotateImage:(UIImage *)image;

@end
