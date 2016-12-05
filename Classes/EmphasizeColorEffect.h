//
//  EmphasizeColorEffect.h
//  FunPhotos
//
//  Created by Paul Welch on 2/25/09.
//  Copyright MetriWorks 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseImageEffect.h"

@interface EmphasizeColorEffect : BaseImageEffect {
	int redLevel;
	int greenLevel;
	int blueLevel;
	int contrastLevel;
	int brightnessLevel;
	bool invert;
	bool grayscale;
}

@property int redLevel;
@property int greenLevel;
@property int blueLevel;
@property int brightnessLevel;
@property int contrastLevel;
@property bool invert;
@property bool grayscale;

@end
