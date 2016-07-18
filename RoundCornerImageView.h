//
//  RoundCornerImage.h
//  startMe
//
//  Created by Matteo Gobbi on 24/08/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoundCornerImageView : UIImageView

-(void)setBorderWidth:(float)width;
-(void)setCornerRadius:(float)radius;
-(void)setBorderColor:(UIColor *)color;
-(void)setCircleMask;

@end
