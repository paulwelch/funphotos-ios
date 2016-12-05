//
//  ClickableImageView.h
//  FunPhotos
//
//  Created by Paul Welch on 4/12/09.
//  Copyright MetriWorks 2009. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ClickableImageView : UIImageView {
	id delegate;
}
@property (assign) id delegate;

@end
