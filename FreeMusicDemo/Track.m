//
//  Track.m
//  FreeMusicDemo
//
//  Created by 曾祺植 on 5/24/15.
//  Copyright (c) 2015 曾祺植. All rights reserved.
//

#import "Track.h"
#import "TrackNetItem.h"

@implementation Track

+ (id)initWithObj:(TrackNetItem *)item
{
    Track *ret = [[Track alloc] initWithObj:item];
    return ret;
}

- (id)initWithObj:(TrackNetItem *)item
{
    self = [super init];
    if (self) {
        self.artist = item.artistName;
        self.title = item.trackName;
        self.audioFileURL = [NSURL URLWithString:item.trackURL];
    }
    return self;
}

@end
