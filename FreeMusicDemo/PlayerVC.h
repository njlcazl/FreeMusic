//
//  PlayerVC.h
//  FreeMusicDemo
//
//  Created by 曾祺植 on 5/24/15.
//  Copyright (c) 2015 曾祺植. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TrackNetItem;
@interface PlayerVC : UIViewController


@property (nonatomic, strong) NSArray *TrackQueue;
@property (nonatomic, strong) TrackNetItem *currentTrack;
@property (nonatomic, strong) NSIndexPath *currentPath;
@property (nonatomic) NSInteger currentIdx;


@end
