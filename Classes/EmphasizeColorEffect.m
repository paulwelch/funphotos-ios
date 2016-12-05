//
//  EmphasizeColorEffect.m
//  FunPhotos
//
//  Created by Paul Welch on 2/25/09.
//  Copyright MetriWorks 2009. All rights reserved.
//

#import "EmphasizeColorEffect.h"

@interface EmphasizeColorEffect(PrivateMethods)
- (void)doEffect:(PIXEL *)data height:(size_t)h width:(size_t)w bytesPerRow:(size_t)bpr;
@end

@implementation EmphasizeColorEffect

@synthesize redLevel;
@synthesize greenLevel;
@synthesize blueLevel;
@synthesize brightnessLevel;
@synthesize contrastLevel;
@synthesize invert;
@synthesize grayscale;

//TODO: pw - make a protocol for effect classes

- (id) init {
    self = [super init];
	
	redLevel = 0;
	greenLevel = 0;
	blueLevel = 0;
	invert = false;
	grayscale = false;
	contrastLevel = 0;
	brightnessLevel = 0;
	
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
			fprintf(stderr, "Creating bitmap context failed");
			[newImage release];
			return Nil;
		}

		size_t w = CGImageGetWidth(newImage.CGImage);
		size_t h = CGImageGetHeight(newImage.CGImage);
		CGRect rect = {{0,0},{w,h}};

		CGContextDrawImage(bitmapContext, rect, newImage.CGImage);
		PIXEL *data = (PIXEL *)CGBitmapContextGetData (bitmapContext);

		//1. do complicated transform logic on raw pixel data in CG context
		[self doEffect:data height:h width:w bytesPerRow:bpr];

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
	//TODO: pw - will the image always have this encoding or do we need to handle others too?  If so, maybe we need to create the context with specific parameters to convert to a known encoding?
	//rgb bit mask
	//BBBB:BBBB GGGG:GGGG RRRR:RRRR AAAA:AAAA
	//0000:0000 0000:0000 0000:0000 0000:0000
	
	//contrast transform map
    int Contrast_transform[255]; 
    //float contrast = .15;//quantifies the angle of the slope (in radians) of the contrast transform  
	float contrast = 0.0;
	if ( contrastLevel > 0.0 && contrastLevel < 100.0  ) contrast = (100.0 - contrastLevel)/100.0;
    for(int i=0;i<256;i++){ 
        if(i<(int)(128.0f+128.0f*tan(contrast))&&i>(int)(128.0f-128.0f*tan(contrast))) 
            Contrast_transform[i]=(i-128)/tan(contrast)+128; 
        else if(i>=(int)(128.0f+128.0f*tan(contrast))) 
            Contrast_transform[i]=255; 
        else 
            Contrast_transform[i]=0; 
    } 
	//end contrast map
    
	//pw - example looping through each pixel, setting the byte array
	for(int i=0; i<h; i++)  //rows
	{
		for(int j=0; j<bpr; j+=(bpr/w))  //pixels in row, increment by bytes per pixel
		{
			int index = (i*bpr)+j;

			Byte alpha = data[index + 3];
			Byte red = data[index + 2];
			Byte green = data[index + 1];
			Byte blue = data[index];
			
			//emphasize color
			red |= redLevel;	
			green |= greenLevel;	
			blue |= blueLevel;   

			//invert
			if(invert)
			{
				red = 255 - red;		
				green = 255 - green;		
				blue = 255 - blue;		
			}
			//end invert
			
			//b&w
//			int avg = (data[index] + data[index] + data[index])/3;			
//			if( avg >= 128 )
//			{
//				data[index] = 255;		
//				data[index+1] = 255;		
//				data[index+2] = 255;		
//			}
//			else {
//				data[index] = 0;		
//				data[index+1] = 0;		
//				data[index+2] = 0;		
//			}
			//end b&w
			
			//grayscale
			if (grayscale)
			{
				int g = (red * .3) + (green * .59) + (blue * .11);
				red = green = blue = g;
			}
			//end grayscale

			//contrast  // 0 to 100 range
			if( contrast > 0 )
			{
				red = Contrast_transform[red]; 
				green = Contrast_transform[green]; 
				blue = Contrast_transform[blue]; 
			}
			//end contrast
			
			//brightness  // -255 to 255 range
			if ( brightnessLevel != 0 )
			{
				int brightR = red + brightnessLevel;
				int brightG = green + brightnessLevel;
				int brightB = blue + brightnessLevel;
				
				if (brightR > 255) brightR = 255;
				if (brightG > 255) brightG = 255;
				if (brightB > 255) brightB = 255;
				if (brightR < 0) brightR = 0;
				if (brightG < 0) brightG = 0;
				if (brightB < 0) brightB = 0;
				
				red = brightR;
				green = brightG;
				blue = brightB;
			}
			//end brightness
			
			//set data
			data[index + 3] = alpha;
			data[index + 2] = red;
			data[index + 1] = green;
			data[index] = blue;		
		}
	}
}


@end
