//
//  ShowAlert.m
//  FreeMusicDemo
//
//  Created by 曾祺植 on 5/17/15.
//  Copyright (c) 2015 曾祺植. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ShowAlert.h"

@implementation ShowAlert

+ (void)showErr:(NSString *)errText
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:errText delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

@end
