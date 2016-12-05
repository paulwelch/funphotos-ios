//
//  ImageEffect.h
//  FunPhotos
//
//  Created by Paul Welch on 2/25/09.
//  Copyright MetriWorks 2009. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef unsigned char PIXEL;

@protocol ImageEffect

-(UIImage *)transformImage:(UIImage *)image; 

@end
