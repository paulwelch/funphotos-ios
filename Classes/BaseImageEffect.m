//
//  BaseImageEffect.m
//  FunPhotos
//
//  Created by Paul Welch on 2/25/09.
//  Copyright MetriWorks 2009. All rights reserved.
//

#import "BaseImageEffect.h"

@interface BaseImageEffect(PrivateMethods)
@end

@implementation BaseImageEffect

static inline double radians (double degrees) {return degrees * M_PI/180;}

@synthesize flipImage;
@synthesize bitmapContext;

- (id) init {
    self = [super init];
	flipImage = NO; //don't flip image unless requested
    return self;
}

- (UIImage *)transformImage:(UIImage *)image
{
	//image = [self fixImageOrientation:image];
	UIImage *newImage = [self scaleAndRotateImage:image]; 
	return newImage;
}

- (int)calcFlippedRow:(int)row height:(size_t) height
{
	if(flipImage)
	{
		row = (int)height - row;
	}
	return row;
}

// Helper method to create BitmapContext for UIImage
- (void)createBitmapContext:(UIImage *)image
{
	@synchronized(self)
	{
		CGBitmapInfo bitmapInfo;
		CGColorSpaceRef colorSpace;
		void *          data;
		int             bytesCnt;
		
		size_t w = CGImageGetWidth(image.CGImage);
		size_t h = CGImageGetHeight(image.CGImage);
		size_t bpc = CGImageGetBitsPerComponent(image.CGImage);
		size_t bpr = CGImageGetBytesPerRow(image.CGImage);
		bitmapInfo = CGImageGetBitmapInfo(image.CGImage);
		colorSpace = CGImageGetColorSpace(image.CGImage);
		bytesCnt      = bpr * h;	
		
		if (colorSpace == NULL)
		{
			NSLog(@"Color Space allocation failed");
			return;
		}
		
		data = malloc( bytesCnt );
		if (data == NULL)
		{
			NSLog(@"Memory allocation failed");
			return;
		}

		//if bitmapContext previously allocated, release before allocating again
		if(bitmapContext != Nil)
		{
			CGContextRelease(bitmapContext);
		}
		
		//CGBitmapContextCreate(<#void * data#>, <#size_t width#>, <#size_t height#>, <#size_t bitsPerComponent#>, <#size_t bytesPerRow#>, <#CGColorSpaceRef colorspace#>, <#CGBitmapInfo bitmapInfo#>)
		bitmapContext = CGBitmapContextCreate (	data,
											   w,
											   h,
											   bpc,
											   bpr,
											   colorSpace,
											   bitmapInfo);
		if (bitmapContext == Nil)
		{
			NSLog(@"Creating context failed");
			free (data);
		}
	}
}

- (void)releaseBitmapContext
{	
	@synchronized(self)
	{
		if(bitmapContext != Nil)
		{
			CGContextRelease(bitmapContext);
		}
	}
}

//TODO: pw - possibly rewrite this more specific to the app
- (UIImage *)scaleAndRotateImage:(UIImage *)image
{
	@synchronized(self)
	{
		int kMaxResolution = [[UIScreen mainScreen] bounds].size.width;
		
		CGImageRef imgRef = image.CGImage;
		
		CGFloat width = CGImageGetWidth(imgRef);
		CGFloat height = CGImageGetHeight(imgRef);
		
		CGAffineTransform transform = CGAffineTransformIdentity;
		CGRect bounds = CGRectMake(0, 0, width, height);
		if (width > kMaxResolution || height > kMaxResolution) {
			CGFloat ratio = width/height;
			if (ratio > 1) {
				bounds.size.width = kMaxResolution;
				bounds.size.height = bounds.size.width / ratio;
			}
			else {
				bounds.size.height = kMaxResolution;
				bounds.size.width = bounds.size.height * ratio;
			}
		}
		
		CGFloat scaleRatio = bounds.size.width / width;
		CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
		CGFloat boundHeight;
		UIImageOrientation orient = image.imageOrientation;
		switch(orient) {
				
			case UIImageOrientationUp: //EXIF = 1
				transform = CGAffineTransformIdentity;
				break;
				
			case UIImageOrientationUpMirrored: //EXIF = 2
				transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
				transform = CGAffineTransformScale(transform, -1.0, 1.0);
				break;
				
			case UIImageOrientationDown: //EXIF = 3
				transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
				transform = CGAffineTransformRotate(transform, M_PI);
				break;
				
			case UIImageOrientationDownMirrored: //EXIF = 4
				transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
				transform = CGAffineTransformScale(transform, 1.0, -1.0);
				break;
				
			case UIImageOrientationLeftMirrored: //EXIF = 5
				boundHeight = bounds.size.height;
				bounds.size.height = bounds.size.width;
				bounds.size.width = boundHeight;
				transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
				transform = CGAffineTransformScale(transform, -1.0, 1.0);
				transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
				break;
				
			case UIImageOrientationLeft: //EXIF = 6
				boundHeight = bounds.size.height;
				bounds.size.height = bounds.size.width;
				bounds.size.width = boundHeight;
				transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
				transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
				break;
				
			case UIImageOrientationRightMirrored: //EXIF = 7
				boundHeight = bounds.size.height;
				bounds.size.height = bounds.size.width;
				bounds.size.width = boundHeight;
				transform = CGAffineTransformMakeScale(-1.0, 1.0);
				transform = CGAffineTransformRotate(transform, M_PI / 2.0);
				break;
				
			case UIImageOrientationRight: //EXIF = 8
				boundHeight = bounds.size.height;
				bounds.size.height = bounds.size.width;
				bounds.size.width = boundHeight;
				transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
				transform = CGAffineTransformRotate(transform, M_PI / 2.0);
				break;
				
			default:
				[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
				
		}
		
		UIGraphicsBeginImageContext(bounds.size);
		
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
			CGContextScaleCTM(context, -scaleRatio, scaleRatio);
			CGContextTranslateCTM(context, -height, 0);
		}
		else {
			CGContextScaleCTM(context, scaleRatio, -scaleRatio);
			CGContextTranslateCTM(context, 0, -height);
		}
		
		CGContextConcatCTM(context, transform);
		
		CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
		UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		return imageCopy;
	}
}

- (void)dealloc
{
	[super dealloc];
}

@end
