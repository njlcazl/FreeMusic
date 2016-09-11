//
//  Track.h
//  FreeMusicDemo
//
//  Created by 曾祺植 on 5/24/15.
//  Copyright (c) 2015 曾祺植. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOUAudioFile.h"
@class TrackNetItem;

@interface Track : NSObject <DOUAudioFile>

@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSURL *audioFileURL;

+ (id)initWithObj:(TrackNetItem *)item;

@end
