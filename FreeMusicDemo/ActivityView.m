//
//  ActivityView.m
//  FCorps
//
//  Created by TT on 14-1-20.
//  Copyright (c) 2014年 http://iwebk.com. All rights reserved.
//

#import "ActivityView.h"
#define kActivityTag    19999
@implementation ActivityView
+ (void)showActivity:(UIView *)target
{
    if (![target viewWithTag:kActivityTag]) {
        UIView *v = [[UIView alloc] init];
        v.translatesAutoresizingMaskIntoConstraints = NO;
        [target addSubview:v];
        [v setBackgroundColor:[UIColor grayColor]];
        [v setAlpha:0.4];
        [v setTag:kActivityTag];
        NSArray *constraint1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view":v}];
        NSArray *constraint2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":v}];
        [target addConstraints:constraint1];
        [target addConstraints:constraint2];

        
        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] init];
        activity.translatesAutoresizingMaskIntoConstraints = NO;
        [v addSubview:activity];
        [activity startAnimating];
        
        NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem:activity attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:v attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint *constraint4 = [NSLayoutConstraint constraintWithItem:activity attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:v attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        [v addConstraint:constraint3];
        [v addConstraint:constraint4];
    }
    
    target.userInteractionEnabled = NO;
}


+ (void)hidenActivity:(UIView *)target
{
    [[target viewWithTag:kActivityTag] removeFromSuperview];
    
    target.userInteractionEnabled = YES;
}
@end
