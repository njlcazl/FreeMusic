//
//  Helper.h
//  FreeMusicDemo
//
//  Created by 曾祺植 on 8/16/15.
//  Copyright (c) 2015 曾祺植. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Helper : NSObject

+ (UIImage *)imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size;
+ (UIImage *)imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth;
@end
