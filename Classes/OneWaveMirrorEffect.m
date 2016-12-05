//
//  OneWaveMirrorEffect.m
//  FunPhotos
//
//  Created by Paul Welch on 2/25/09.
//  Copyright MetriWorks 2009. All rights reserved.
//

#import "OneWaveMirrorEffect.h"

@interface OneWaveMirrorEffect(PrivateMethods)
- (void)doEffect:(PIXEL *)data height:(size_t)h width:(size_t)w bytesPerRow:(size_t)bpr;
@end

@implementation OneWaveMirrorEffect

@synthesize emphasis;

- (id) init {
    self = [super init];
    return self;
}

- (UIImage *)transformImage:(UIImage *)image 
{
	@synchronized(self)
	{
		UIImage *newImage = [[super transformImage:image] retain];	

		//get info about image structure
		size_t bpc = CGImageGetBitsPerComponent(image.CGImage);
		size_t bpp = CGImageGetBitsPerPixel(image.CGImage);
		size_t bpr = CGImageGetBytesPerRow(image.CGImage);  
		CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(image.CGImage);
		CGColorSpaceRef colorSpaceRef = CGImageGetColorSpace(image.CGImage);	
		
		[self createBitmapContext:image];
		if (bitmapContext == NULL)
		{
			// error creating context
			NSLog(@"Creating bitmap context failed");
			[newImage release];
			return Nil;
		}
		
		size_t w = CGImageGetWidth(image.CGImage);
		size_t h = CGImageGetHeight(image.CGImage);
		CGRect rect = {{0,0},{w,h}};
		
		CGContextDrawImage(bitmapContext, rect, image.CGImage);
		PIXEL *data = (PIXEL *)CGBitmapContextGetData (bitmapContext);
		
		//1. do complicated transform logic on raw pixel data in CG context
		for (int i=0; i<emphasis; i++) {
			[self doEffect:data height:h width:w bytesPerRow:bpr];
		}
		
		//2. set image from modified pixel data in CG context
		CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, data, bpr * h, NULL);
		CGImageRef cgImage = CGImageCreate(w, h, bpc, bpp, bpr, colorSpaceRef, bitmapInfo, dataProvider, NULL, false, kCGRenderingIntentDefault);

		[newImage release];
		newImage = [[UIImage alloc] initWithCGImage:cgImage];
		
		if(cgImage != Nil)
		{
			CGImageRelease(cgImage);
		}
		if(dataProvider != Nil)
		{
			CGDataProviderRelease(dataProvider);
		}
		
		// Free image data memory for the context
		[self releaseBitmapContext];
		
		return [newImage autorelease];		
	}
}

- (void)doEffect:(PIXEL *)data height:(size_t)h width:(size_t)w bytesPerRow:(size_t)bpr
{
	PIXEL * dataBuf = malloc(bpr*h);
	dataBuf = memcpy(dataBuf, data, bpr*h);
	double const pi = 2 * acos(0.0);
	
	int startRow = 0;  
	int endRow = h-startRow;
	int srcRow;
	int rowCount = endRow - startRow;
	
	for(int i=0; i<h; i++)  //rows
	{
		//srcRow = sin((((float)(rowCount-i))/rowCount)*pi)*(rowCount/2);
		srcRow = sin((((float)(abs(rowCount-i)))/rowCount)*pi)*(rowCount/2);
		if( i > (rowCount/2) )
		{
			srcRow = rowCount - srcRow;
		}
		for(int j=0; j<bpr; j++)  //pixels in row, increment by bytes per pixel
		{
			data[(i*bpr)+j]   = (dataBuf[(srcRow*bpr)+j]);	    
		}
	}
	free(dataBuf);
}

@end
