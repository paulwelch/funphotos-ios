//
//  TwoWaveMirrorEffect.m
//  FunPhotos
//
//  Created by Paul Welch on 2/25/09.
//  Copyright MetriWorks 2009. All rights reserved.
//

#import "TwoWaveMirrorEffect.h"

@interface TwoWaveMirrorEffect(PrivateMethods)	
- (void)doEffect:(PIXEL *)data height:(size_t)h width:(size_t)w bytesPerRow:(size_t)bpr;
@end

@implementation TwoWaveMirrorEffect

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
		size_t bpc = CGImageGetBitsPerComponent(newImage.CGImage);
		size_t bpp = CGImageGetBitsPerPixel(newImage.CGImage);
		size_t bpr = CGImageGetBytesPerRow(newImage.CGImage);  
		CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(newImage.CGImage);
		CGColorSpaceRef colorSpaceRef = CGImageGetColorSpace(newImage.CGImage);	
		
		[self createBitmapContext:newImage];
		if (bitmapContext == NULL)
		{
			// error creating context
			NSLog(@"Creating bitmap context failed");
			[newImage release];
			return Nil;
		}
		
		size_t w = CGImageGetWidth(newImage.CGImage);
		size_t h = CGImageGetHeight(newImage.CGImage);
		CGRect rect = {{0,0},{w,h}};
		
		CGContextDrawImage(bitmapContext, rect, newImage.CGImage);
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
	int rowCount = endRow - startRow - 1;
	//TODO: there should be a way to compute these without making assumptions about how many waves - currently only works for 2
	int waveCount = 2;
	int rowsPerWave = (rowCount/waveCount);
	
	for(int i=0; i<h; i++)  //rows
	{
		int destRow = [self calcFlippedRow:i height:h]; 
		float n = (float)(abs(rowsPerWave-i));
		
		//might be better to do rowsPerWave/2 instead of rowsPerWave/waveCount
		srcRow = sin((n/rowsPerWave)*pi)*(rowsPerWave/waveCount);
		
		int rc = (int)i/((int)rowsPerWave/waveCount);
		switch (rc) {
			case 0:
				break;
			case 1:
				srcRow = rowsPerWave - srcRow;
				break;
			case 2:
				srcRow = srcRow + rowsPerWave;
				break;
			case 3:
				srcRow = (waveCount*rowsPerWave) - srcRow;
				break;
			default:
				break;
		}
		
		for(int j=0; j<bpr; j++)  //pixels in row, increment by bytes per pixel
		{
			data[(destRow*bpr)+j] = (dataBuf[(srcRow*bpr)+j]);	
		}
	}
	free(dataBuf);
}


@end
